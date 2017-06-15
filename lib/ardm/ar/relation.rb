require 'active_support/concern'
require 'ardm/ar/collection'

module Ardm
  module Ar
    module Relation
      extend ActiveSupport::Concern

      included do
        alias_method :destory_without_ardm, :destroy
        alias_method :update_without_ardm, :update
        alias_method :first_without_ardm, :first
        alias_method :first_without_ardm!, :first!
        alias_method :equal_without_ardm!, :==

        # we need to overrite the implementation in the class
        class_eval do
          def ==(other)
            result = self.equal_without_ardm!(other)
            if !result && other.is_a?(Relation)
              result ||= self.equal_without_ardm!(other.to_a)
            end
            result
          end

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

          def first(*args)
            if args.any?
              all(*args).first_without_ardm
            else
              first_without_ardm
            end
          end

          def first!(*args)
            if args.any?
              all(*args).first_without_ardm!
            else
              first_without_ardm!
            end
          end

          def first_or_create(attributes = nil, options = {}, &block)
            all(attributes).first || all(attributes).create(options, &block)
          end

          def first_or_create!(attributes = nil, options = {}, &block)
            all(attributes).first || all(attributes).create!(options, &block)
          end

          def first_or_initialize(attributes = nil, options = {}, &block)
            all(attributes).first || all(attributes).create(options, &block)
          end
        end
      end

      def method_missing(meth, *a, &b)
        super
      rescue => e
        raise NoMethodError, "Relation chain? #{self}.#{meth}\n#{e}"
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
      def apply_finder_options(options, *args)
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
          if value.is_a?(ActiveRecord::Relation)
            value = value.to_a
          end
          key_to_reflect_on = key
          if key.is_a?(Ardm::Query::Operator)
            key_to_reflect_on = key.target
          end
          if assoc = relation.reflect_on_association(key_to_reflect_on)
            conditions.delete(key)
            # strip out assocations
            puts "assoc.macro #{assoc.macro} -- #{options.inspect}"
            case assoc.macro
            when :belongs_to
              if key.is_a?(Ardm::Query::Operator)
                #TODO: might not work for all types of value... but works when value is nil (existing DM specs drive development)
                relation = key.to_arel(self, value).scope
              else
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
                           relation.where(parent_key => value.send(foreign_key))
                         elsif value.is_a?(::ActiveRecord::Relation)
                           relation.where(parent_key => value.select(foreign_key))
                         elsif value.nil?
                           if key.is_a?(Ardm::Query::Operator) && (key.operator == :not_eq)
                             relation.where(parent_key => foreign_class.select(foreign_key).compact.map(&foreign_key).to_a)
                           else
                             relation.where.not(parent_key => foreign_class.select(foreign_key).compact.map(&foreign_key).to_a)
                           end
                           #should EQ:
                           # relation.select{|o| o.send(assoc.name) == value}
                         elsif value.is_a?(::Array) && value.first.is_a?(::ActiveRecord::Base)
                           foreign_key_values = value.map(&foreign_key.to_sym)
                           relation.where(parent_key => foreign_key_values)
                         else
                           relation.where(parent_key => foreign_class.select(foreign_key).where(value))
                         end
            when :has_many
              foreign_class = assoc.options[:class_name].constantize
              foreign_key   = assoc.foreign_key
              parent_key    = assoc.options[:child_key] || klass.primary_key

              relation = if value.is_a?(::ActiveRecord::Base)
                           relation.where(id: foreign_class.where(parent_key => value.send(parent_key)).map(&foreign_key))
                         elsif value.is_a?(Hash)
                           relation.where(id: foreign_class.where(parent_key => value[parent_key.to_s]).map(&foreign_key))
                         elsif value.is_a?(::ActiveRecord::Relation)
                           relation.where(id: foreign_class.where(parent_key => value.select(parent_key).to_a).map(&foreign_key))
                         elsif value.is_a?(Array)
                           relation.where(id: foreign_class.where(parent_key => value.map{|v| v.send(parent_key)}).map(&foreign_key))
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

      def query
        self.to_sql
      end

      def ==(other)
        puts "COMPARING to #{other}"
        super(other)
      end

      def destroy!
        delete_all
      end
    end
  end
end
