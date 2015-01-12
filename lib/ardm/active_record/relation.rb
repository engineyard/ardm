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

        debug = Proc.new do |x|
          # un-comment here for ALL THE PUTS:
          if ENV["DEBUG"]
            puts x
          end
        end

        conditions.each do |key, value|

          if value.is_a?(Hash)
            value = value.with_indifferent_access[:id]
          end

          unmodified_key = key
          the_positive = true
          if key.is_a?(Ardm::Query::Operator)
            if assoc = relation.reflect_on_association(key.target)
              debug.call "IT's an Operator #{key.target}.#{key.operator} on an association #{assoc.inspect}"
              if key.operator == :not_eq
                the_positive = false
              else
                raise "Fail. can't apply #{key.target}.#{key.operator} because #{key.target} is an association."
              end
            end
            key = key.target
          end
          assoc = relation.reflect_on_association(key)

          fallback = Proc.new do
            debug.call "checking all of #{relation.size} things for #{key} == #{value.inspect}"
            select_matching = relation.select do |x|
              debug.call "given #{x.inspect}"
              actual = x.send(key)
              expected = value
              debug.call "in #{the_positive} actual #{actual.inspect} \nvs expected #{expected.inspect}"
              if expected.is_a?(::ActiveRecord::Relation)
                if actual.is_a?(::ActiveRecord::Relation)
                  if the_positive
                    result = (actual.to_a == expected.to_a)
                  else
                    result = (actual.to_a != expected.to_a)
                  end
                else
                  if the_positive
                    result = expected.to_a.include?(actual)
                  else
                    result = !expected.to_a.include?(actual)
                  end
                end
              elsif expected.is_a?(Fixnum)
                if actual.is_a?(::ActiveRecord::Relation)
                  if the_positive
                    result = actual.map(&:id).include?(expected)
                  else
                    result = !actual.map(&:id).include?(expected)
                  end
                else
                  if the_positive
                    result = (actual.try(:id) == expected)
                  else
                    result = (actual.try(:id) != expected)
                  end
                end
              elsif expected.nil?
                if actual.is_a?(::ActiveRecord::Relation)
                  if the_positive
                    result = actual.empty?
                  else
                    result = !actual.empty?
                  end
                else
                  if the_positive
                    result = actual.nil?
                  else
                    result = !actual.nil?
                  end
                end
              else
                if actual.is_a?(::ActiveRecord::Relation)
                  if the_positive
                    result = actual.include?(expected)
                  else
                    result = !actual.include?(expected)
                  end
                else
                  if the_positive
                    result = (actual == expected)
                  else
                    result = (actual != expected)
                  end
                end
              end
              debug.call "result #{result}"
              result
            end
            relation.where(id: select_matching)
          end

          set_relation = Proc.new do |new_relation_proc|
            debug.call "the_positive #{the_positive}"
            debug.call caller[0]
            begin
              new_relation = new_relation_proc.call
              if ENV["DEBUG"]
                selected = fallback.call.to_a
                puts "comparing #{new_relation.to_a} with #{selected}"
                unless new_relation.to_a == selected
                  puts "MATCHING FAILED HERE -- #{new_relation.to_a} vs #{selected}"
                  puts caller
                end
              end
              relation = new_relation
            rescue => e
              if ENV["DEBUG"]
                puts e.inspect
                puts e.backtrace
                puts "USING FALLBACK, you should really pry this spot and figure it out"
                relation = fallback.call
              else
                raise e
              end
            end
          end

          if assoc
            conditions.delete(unmodified_key)

            # TODO: still need this?
            # if value.is_a?(::Array) && value.empty?
            #   # @fixme: dm basically no-ops cause it knows you are stupid
            #   return klass.where(klass.primary_key => nil)
            # end

            if relation.klass == assoc.options[:class_name].try(:constantize)
              debug.call "Special handling would be needed for #{key} => #{value} on #{relation.klass}. falling back to iteration and comparison"
              relation = fallback.call
            else
              # strip out assocations
              case assoc.macro
              when :belongs_to
                if value.is_a?(::ActiveRecord::Relation)
                  if value.values.empty?
                    set_relation[->{relation.where.not(assoc.foreign_key => nil)}]
                  else
                    set_relation[->{relation.where(assoc.foreign_key => value)}]
                  end
                else
                  if the_positive
                    set_relation[->{relation.where(assoc.foreign_key => value)}]
                  else
                    set_relation[->{relation.where.not(assoc.foreign_key => value)}]
                  end
                end
              when :has_one
                foreign_class = assoc.options[:class_name].constantize
                foreign_key   = assoc.foreign_key
                parent_key    = assoc.options[:child_key] || klass.primary_key

                if value.is_a?(::Array) && value.empty?
                  # @fixme: dm basically no-ops cause it knows you are stupid
                  return set_relation[->{klass.where(klass.primary_key => nil)}]
                end

                if value.is_a?(::ActiveRecord::Base)
                  set_relation[->{relation.where(parent_key => value.send(assoc.foreign_key))}]
                elsif value.is_a?(::ActiveRecord::Relation)
                  if the_positive
                    set_relation[->{relation.where(parent_key => value.select(&foreign_key))}]
                  else
                    set_relation[->{relation.where.not(parent_key => value.select(&foreign_key))}]
                  end
                elsif value.nil?
                  set_relation[->{relation.where.not(parent_key => foreign_class.select(&foreign_key).where.not(foreign_key => value))}]
                else
                  set_relation[->{relation.where(parent_key => foreign_class.select(&foreign_key).where(value))}]
                end
              when :has_many
                if assoc.options[:through]
                  debug.call "Special handling would be needed for has_many through. #{key} => #{value} on #{relation.klass}. falling back to iteration and comparison"
                  relation = fallback.call
                else
                  foreign_class = assoc.options[:class_name].constantize
                  foreign_key   = assoc.foreign_key
                  parent_key    = assoc.options[:child_key] || klass.primary_key

                  if value.is_a?(::ActiveRecord::Relation)
                    set_relation[->{relation.where(foreign_key => value)}]
                  else
                    set_relation[->{relation.where(parent_key => foreign_class.select(foreign_class.primary_key).where.not(foreign_key => value))}]
                  end
                end
              else
                raise("unknown: #{assoc.inspect}")
              end
            end
          end
        end

        processed_conditions = {}

        conditions.each do |key, value|
          debug.call "remaining conditions #{key}"
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

      def method_missing(meth, *args, &b)
        association = reflect_on_association(meth.to_sym) ||
                      reflect_on_association(meth.to_s.singularize.to_sym) ||
                      reflect_on_association(meth.to_s.pluralize.to_sym)
        if association
          ids = self.map(&association.name)
          result = association.klass.all(id: ids)
          if args.empty?
            result
          else
            result.all(*args)
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
