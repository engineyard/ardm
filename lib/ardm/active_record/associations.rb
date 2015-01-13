

module Ardm
  module ActiveRecord
    module Associations
      extend ActiveSupport::Concern

      # Convert options from DM style to AR style.
      #
      # Keep any unknown keys to use as conditions.
      def self.convert_options(klass, options, *keep)
        keep += [:class_name, :foreign_key]

        ar = options.dup
        ar[:class_name]  = ar.delete(:model)      if ar[:model]
        ar[:foreign_key] = ar.delete(:child_key)  if ar[:child_key]
        ar[:foreign_key] = ar[:foreign_key].first if ar[:foreign_key].respond_to?(:to_ary)

        if ar[:foreign_key] && property = klass.properties[ar[:foreign_key]]
          ar[:foreign_key] = property.field
        end

        if Ardm.rails3?
          if (conditions = ar.slice!(*keep)).any?
            ar[:conditions] = conditions
          end
          [ar]
        else
          order = ar.delete(:order)
          conditions = ar.slice!(*keep)
          # sigh
          block = if conditions.any? && order
                    lambda { where(conditions).order(order) }
                  elsif conditions.any?
                    lambda { where(conditions) }
                  elsif order
                    lambda { order(order) }
                  end
          [block, ar].compact
        end
      end

      module ClassMethods
        # The reflections returned here don't look like datamapper relationships.
        # @todo improve this if needed with a wrapper
        def relationships
          reflections
        end

        def dump_associations_hash(options)
          options.inject({}) do |new_attrs, (key, value)|
            if reflection = reflect_on_association(key.to_sym)
              if value.is_a?(ActiveRecord::Base)
                new_attrs[reflection.foreign_key] = value.id
                if reflection.respond_to?(:polymorphic?) && reflection.polymorphic?
                  new_attrs[reflection.foreign_type] = value.class.base_class
                end
              else
                new_attrs[reflection.foreign_key] = value
              end
            else
              new_attrs[key] = value
            end
            new_attrs
          end
        end

        def belongs_to(field, *args)
          options = args.shift || {}

          if String === options || Class === options # belongs_to :name, 'Class', options: 'here'
            options = (args.last || {}).merge(:model => options.to_s)
          end

          unless Hash === options
            raise ArgumentError, "bad belongs_to #{field} options format #{options.inspect}"
          end

          options.delete(:default)
          options.delete(:required)
          opts = Ardm::ActiveRecord::Associations.convert_options(self, options)
          super field, *opts
          assoc = reflect_on_association(field)
          Ardm::ActiveRecord::Record.on_finalize << lambda do
            self.class_eval do
              property assoc.foreign_key, assoc.klass.key.first.class, key: false
            end
          end
          nil
        end

        def n
          "many"
        end

        def has(count, name, *args)
          options = args.shift || {}

          if String === options || Class === options # has n, :name, 'Class', options: 'here'
            options = (args.last || {}).merge(:model => options.to_s)
          end

          unless Hash === options
            raise ArgumentError, "bad has #{count} options format #{options.inspect}"
          end

          options[:order] = Ardm::ActiveRecord::Query.order(self, options[:order]) if options[:order]
          opts = Ardm::ActiveRecord::Associations.convert_options(self, options, :through, :order)

          case count
          when 1      then has_one  name, *opts
          when "many" then has_many name, *opts
          end
        end

      end
    end
  end
end
