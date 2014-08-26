require 'active_support/concern'
require 'ardm/active_record/collection'

module Ardm
  module ActiveRecord
    module Relation
      extend ActiveSupport::Concern

      included do
        alias_method :destory_without_ardm, :destroy
        alias_method :update_without_ardm, :update

        # we need to overrite the implementation in the class
        class_eval do
          def update(*a)
            if a.size == 1
              # need to translate attributes
              options = @klass.dump_properties_hash(a.first)
              options = @klass.dump_associations_hash(options)
              update_all(options)
            else
              update_without_ardm(*a)
            end
          end

          def destroy(id = nil)
            if id
              destroy_without_ardm(id)
            else
              destroy_all
            end
          end

          def first_or_create(attributes = nil, options = {}, &block)
            first(attributes) || create(attributes, options, &block)
          end

          def first_or_create!(attributes = nil, options = {}, &block)
            first(attributes) || create!(attributes, options, &block)
          end

          def first_or_initialize(attributes = nil, options = {}, &block)
            first(attributes) || create(attributes, options, &block)
          end
        end
      end

      def all(options={})
        apply_finder_options(options)
      end

      #def apply_finder_options(options)
      #  return super if options.nil? || options.empty?
      #  options = options.dup
      #  conditions = options.slice!(*::ActiveRecord::SpawnMethods::VALID_FIND_OPTIONS)
      #  super(options).where(conditions)
      #end

      VALID_FIND_OPTIONS = [ :conditions, :include, :joins, :limit, :offset, :extend,
                             :order, :select, :readonly, :group, :having, :from, :lock ]

      # We used to just patch this, like above, but we need to copy it over
      # completely for rails4 since it no longer supports the old style finder
      # methods that act more like the datamapper finders.
      def apply_finder_options(options)
        relation = clone
        return relation if options.nil?

        finders = options.dup
        finders[:select] = finders.delete(:fields)
        conditions = finders.slice!(*VALID_FIND_OPTIONS)

        finders.delete_if { |key, value| value.nil? && key != :limit }

        ([:joins, :select, :group, :order, :having, :limit, :offset, :from, :lock, :readonly] & finders.keys).each do |finder|
          relation = relation.send(finder, finders[finder])
        end

        conditions.each do |key, value|
          if assoc = relation.reflect_on_association(key)
            conditions.delete(key)
            # strip out assocations
            case assoc.macro
            when :belongs_to
              id = value.is_a?(Hash) ? value.with_indifferent_access[:id] : value
              relation = if value.is_a?(::ActiveRecord::Relation)
                           if value.values.empty?
                             relation.where.not(assoc.foreign_key => nil)
                           else
                             relation.where(assoc.foreign_key => value)
                           end
                         else
                           relation.where(assoc.foreign_key => id)
                         end
            when :has_one
              foreign_class = assoc.options[:class_name].constantize
              foreign_key   = assoc.foreign_key
              parent_key    = assoc.options[:child_key] || klass.primary_key

              if value.is_a?(::Array) && value.empty?
                # @fixme: dm basically no-ops cause it knows you are stupid
                return klass.where(klass.primary_key => nil)
              end

              relation = if value.is_a?(::ActiveRecord::Base)
                           relation.where(parent_key => value.send(assoc.foreign_key))
                         elsif value.is_a?(::ActiveRecord::Relation)
                           relation.where(parent_key => value.select(foreign_key))
                         elsif value.nil?
                           relation.where.not(parent_key => foreign_class.select(foreign_key).where.not(foreign_key => value))
                         else
                           relation.where(parent_key => foreign_class.select(foreign_key).where(value))
                         end
            when :has_many
              foreign_class = assoc.options[:class_name].constantize
              foreign_key   = assoc.foreign_key
              parent_key    = assoc.options[:child_key] || klass.primary_key

              relation = if value.is_a?(::ActiveRecord::Relation)
                           relation.where(foreign_key => value)
                         else
                           relation.where(parent_key => foreign_class.select(foreign_class.primary_key).where.not(foreign_key => value))
                         end
            else
              raise("unknown: #{assoc.inspect}")
            end
          end
        end

        processed_conditions = {}

        conditions.each do |key, value|
          key = key.is_a?(Ardm::Property) ? key.name : key

          case key
          when String, Symbol then
            processed_conditions[key] = value
          when Ardm::Query::Operator then
            relation = key.to_arel(self, value).scope
          else raise "unknown key: #{key.inspect} #{value.inspect}"
          end
        end

        relation = relation.where(processed_conditions) if processed_conditions.any?
        relation = relation.where(finders[:conditions]) if options.has_key?(:conditions)
        relation = relation.includes(finders[:include]) if options.has_key?(:include)
        relation = relation.extending(finders[:extend]) if options.has_key?(:extend)

        relation
      end


      def calculate(operation, column_name, options={})
        if property = properties[column_name]
          column_name = property.field
        end
        super(operation, column_name, options)
      end

      def method_missing(meth, *a, &b)
        if a.empty? && association = reflect_on_association(meth.to_sym)
          case association.macro
          when :belongs_to
            association.klass.where(klass.primary_key => self.select(association.foreign_key))
          when :has_many, :has_one
            association.klass.where(association.foreign_key => self.clone)
          end
        else
          super
        end
      end

      def destroy!
        delete_all
      end
    end
  end
end
