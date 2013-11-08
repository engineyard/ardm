require 'active_support/concern'
require 'active_record'

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
              options = @klass.send(:dump_properties_hash, a.first)
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

      def apply_finder_options(options)
        return super if options.nil? || options.empty?
        options = options.dup
        conditions = options.slice!(*::ActiveRecord::SpawnMethods::VALID_FIND_OPTIONS)
        super(options).where(conditions)
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
