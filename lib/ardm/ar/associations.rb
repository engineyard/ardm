

module Ardm
  module Ar
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
        ar[:source]      = ar.delete(:via)        if ar[:via]
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

        def belongs_to(name, *args)
          options = args.shift || {}

          if String === options || Class === options # belongs_to :name, 'Class', options: 'here'
            options = (args.last || {}).merge(:model => options.to_s)
          end

          unless Hash === options
            raise ArgumentError, "bad belongs_to #{name} options format #{options.inspect}"
          end

          if options.has_key?(:key) || options.has_key?(:unique)
            raise Ardm::NotImplemented, "belongs to :key and :unique are not implemented."
          end

          options.delete(:default)
          required = options.delete(:required)
          opts = Ardm::Ar::Associations.convert_options(self, options)
          super name, *opts

          model = self
          Ardm::Ar::Finalize.on_finalize do
            return @child_key if defined?(@child_key)

            properties = model.properties
            assoc = reflect_on_association(name)

            property_name = assoc.foreign_key
            target_property = assoc.klass.properties.key.first

            properties[property_name] || begin
              source_key_options = Ardm::Ext::Hash.only(target_property.options, :length, :precision, :scale, :min, :max).update(
                :index    => name,
                :required => (required == false ? false : true),
                :key      => false,
                :unique   => false
              )
              model.property(property_name, target_property.to_child_key, source_key_options)
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

          options[:order] = Ardm::Ar::Query.order(self, options[:order]) if options[:order]
          opts = Ardm::Ar::Associations.convert_options(self, options, :through, :order, :source)

          case count
          when 1      then has_one  name, *opts
          when "many" then has_many name, *opts
          end
        end

      end
    end
  end
end
