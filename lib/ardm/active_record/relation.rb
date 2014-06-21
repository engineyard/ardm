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
            case assoc.macro
            when :belongs_to
              id = value.is_a?(Hash) ? value.with_indifferent_access[:id] : value
              relation = relation.where(assoc.foreign_key => id)
            when :has_many
              foreign_class = assoc.options[:class_name].constantize
              foreign_key   = assoc.options[:foreign_key]
              parent_key    = assoc.options[:child_key] || klass.primary_key

              relation = relation.where(
                parent_key => foreign_class.select(foreign_class.primary_key).where.not(foreign_key => value))
            else raise("unknown: #{assoc.inspect}")
            end
          end
        end

        relation = relation.where(conditions)           if conditions.any?
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
