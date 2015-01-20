require 'active_support/concern'

module Ardm
  module Ar
    module PredicateBuilder
      module Rails4
        extend ActiveSupport::Concern

        Base     = ::ActiveRecord::Base
        Relation = ::ActiveRecord::Relation

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

            #
            # attributes {
            #   Ardm::Query::Operator(target: :attr, operator: :not) =>
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
                  operator = column.operator
                  target_column = column.target.to_s
                else
                  target_column = column.to_s
                  operator = nil
                end

                if target_column.include?('.')
                  table_name, target_column = target_column.split('.', 2)
                  table = Arel::Table.new(table_name, default_table.engine)
                end

                query = expand(klass, table, target_column, value)
                # TODO make nicer
                if [:not_eq, :not_in].include?(operator)
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
            if klass && association = klass.reflect_on_association(column.to_sym)
              expand_association(association, table, column, value)
            else
              [build(table[column], value)]
            end
          end

          # Find the foreign key when using queries such as:
          # Post.where(author: author)
          #
          # For polymorphic relationships, find the foreign key and type:
          # PriceEstimate.where(estimate_of: treasure)
          #
          # Attempt to build a query that makes sense for an association name
          # in the query, but if we can't generate a propery query, fallback
          # to using the original key we received.
          def expand_association(association, table, column, value)
            queries = []
            case association.macro
            when :belongs_to
              if association.polymorphic? && base_class = polymorphic_base_class_from_value(value)
                queries << build(table[association.foreign_type], base_class)
              end
              queries << build(table[association.foreign_key], value)
            when :has_many, :has_one
              table = Arel::Table.new(association.klass.table_name, table.engine)
              queries << build(table[association.klass.primary_key], value)
            else
              queries << build(table[column], value)
            end
            queries
          end

          def polymorphic_base_class_from_value(value)
            case value
            when Relation
              value.klass.base_class
            when Array
              val = value.compact.first
              val.class.base_class if val.is_a?(Base)
            when Base
              value.class.base_class
            end
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
