require 'active_support/concern'

module Ardm
  module ActiveRecord
    module PredicateBuilder
      module Rails3
        extend ActiveSupport::Concern

        Base       = ::ActiveRecord::Base
        Relation   = ::ActiveRecord::Relation
        Collection = ::ActiveRecord::Associations::CollectionProxy

        included do
          class << self
            alias_method :original_build_from_hash, :build_from_hash
          end

          class_attribute :handlers
          self.handlers = []

          register_handler(BasicObject, ->(attribute, value) { attribute.eq(value) })
          register_handler(Class, ->(attribute, value) { attribute.eq(value.name) })
          register_handler(Base, ->(attribute, value) { attribute.eq(value.id) })
          register_handler(Range, ->(attribute, value) { attribute.in(value) })
          register_handler(Relation, RelationHandler.new)
          register_handler(Collection, ArrayHandler.new)
          register_handler(Array, ArrayHandler.new)
        end

        module ClassMethods
          def resolve_column_aliases(klass, hash)
            hash = hash.dup
            hash.keys.grep(Symbol) do |key|
              if klass.attribute_alias? key
                hash[klass.attribute_alias(key)] = hash.delete key
              end
            end
            hash
          end

          def build_from_hash(klass, attributes, default_table)
            queries = []
            # HAX (this method is added to the attributes hash by expand_hash_conditions_for_aggregates
            # Rails 3 calls build_form_hash with the first arg that is not the klass.
            klass = attributes.klass

            attributes.each do |column, value|
              table = default_table

              if value.is_a?(Hash)
                if value.empty?
                  queries << '1=0'
                else
                  table       = Arel::Table.new(column, default_table.engine)
                  association = klass.reflect_on_association(column.to_sym)

                  value.each do |k, v|
                    queries.concat expand(association && association.klass, table, k, v)
                  end
                end
              else
                if Ardm::Query::Operator === column
                  original = column
                  operator = column.operator
                  column   = column.target.to_s
                else
                  column = column.to_s
                end

                if column.include?('.')
                  table_name, column = column.split('.', 2)
                  table = Arel::Table.new(table_name, default_table.engine)
                end

                query = expand(klass, table, column, value)
                # TODO make nicer
                if operator == :not
                  # Logical not factorization !(a && b) == (!a || !b)
                  query.map! &:not
                  query = [query.inject { |composite, predicate| composite.or(predicate) }]
                end
                queries.concat query
              end
            end

            queries
          end

          def expand(klass, table, column, value)
            queries = []

            # Find the foreign key when using queries such as:
            # Post.where(author: author)
            #
            # For polymorphic relationships, find the foreign key and type:
            # PriceEstimate.where(estimate_of: treasure)
            if klass && reflection = klass.reflect_on_association(column.to_sym)
              if value.is_a?(Base) && reflection.respond_to?(:polymorphic?) && reflection.polymorphic?
                queries << build(table[reflection.foreign_type], value.class.base_class)
              end

              column = reflection.foreign_key
            end

            queries << build(table[column], value)
            queries
          end

          def references(attributes)
            attributes.map do |key, value|
              if value.is_a?(Hash)
                key
              else
                key = key.to_s
                key.split('.').first if key.include?('.')
              end
            end.compact
          end

          # Define how a class is converted to Arel nodes when passed to +where+.
          # The handler can be any object that responds to +call+, and will be used
          # for any value that +===+ the class given. For example:
          #
          #     MyCustomDateRange = Struct.new(:start, :end)
          #     handler = proc do |column, range|
          #       Arel::Nodes::Between.new(column,
          #         Arel::Nodes::And.new([range.start, range.end])
          #       )
          #     end
          #     ActiveRecord::PredicateBuilder.register_handler(MyCustomDateRange, handler)
          def register_handler(klass, handler)
            handlers.unshift([klass, handler])
          end

          private

          def build(attribute, value)
            handler_for(value).call(attribute, value)
          end

          def handler_for(object)
            handlers.detect { |klass, _| klass === object }.last
          end
        end
      end
    end
  end
end
