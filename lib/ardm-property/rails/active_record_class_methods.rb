module Ardm
  class Property
    module Rails
      module ActiveRecordClassMethods
        def self.extended(model)
          model.instance_variable_set(:@properties,               PropertySet.new)
          model.instance_variable_set(:@field_naming_convention, nil)
          #model.send :after_initialize, :initialize_ardm_property_defaults
          model.send :before_validation, :initialize_ardm_property_defaults

          super
        end

        def inherited(model)
          model.instance_variable_set(:@properties,               PropertySet.new)
          model.instance_variable_set(:@field_naming_convention, @field_naming_convention)

          model_properties = model.properties
          @properties.each { |property| model_properties << property }

          super
        end

        # Defines a Property on the Resource
        #
        # @param [Symbol] name
        #   the name for which to call this property
        # @param [Class] type
        #   the ruby type to define this property as
        # @param [Hash(Symbol => String)] options
        #   a hash of available options
        #
        # @return [Property]
        #   the created Property
        #
        # @see Property
        #
        # @api public
        def property(name, type, options = {})
          # if the type can be found within Property then
          # use that class rather than the primitive
          klass = Ardm::Property.determine_class(type)

          unless klass
            raise ArgumentError, "+type+ was #{type.inspect}, which is not a supported type"
          end

          property = klass.new(self, name, options)

          self.properties << property

          # add the property to the child classes only if the property was
          # added after the child classes' properties have been copied from
          # the parent
          descendants.each do |descendant|
            descendant.properties << property
          end

          serialize(property.field, property)

          set_primary_key_for(property)
          create_reader_for(property)
          create_writer_for(property)
          add_validations_for(property)

          # FIXME: explicit return needed for YARD to parse this properly
          return property
        end

        # Gets a list of all properties that have been defined on this Model
        #
        # @return [PropertySet]
        #   A list of Properties defined on this Model in the given Repository
        #
        # @api public
        def properties
          @properties ||= PropertySet.new
        end

        def initialize_attributes(attributes, options = {})
          super(attributes, options)

          properties.each do |property|
            if attributes.key?(property.name)
              attributes[property.field] = attributes[property.name]
            end
          end

          attributes
        end

        def columns
          @columns ||= properties.map do |property|
            sql_type = connection.type_to_sql(
              property.dump_as.name.to_sym,
              property.options[:limit],
              property.options[:precision],
              property.options[:scale]
            )

            column = ActiveRecord::ConnectionAdapters::Column.new(
              #property.name.to_s,
              property.field.to_s,
              nil,#property.dump(property.default),
              sql_type,
              property.allow_nil?
            )

            column.primary = property.key?
            column
          end
        end

        # Hook into the query system when we would be finding composed_of
        # fields in active record. This lets us mangle the query as needed.
        #
        # Every DM property needs to be dumped when it's being sent to a query.
        # This also gives us a chance to handle aliased fields
        def expand_hash_conditions_for_aggregates(*args)
          dump_properties_hash(super)
        end

        def dump_properties_hash(options)
          options.inject({}) do |new_attrs, (key, value)|
            if property = properties[key]
              new_attrs[property.field] = property.dump(value)
            else
              new_attrs[key] = value
            end
            new_attrs
          end
        end

        # Gets the list of key fields for this Model
        #
        # @return [Array]
        #   The list of key fields for this Model
        #
        # @api public
        def key
          properties.key
        end

        # @api public
        def serial
          key.detect { |property| property.serial? }
        end

        # Gets the field naming conventions for this resource in the given Repository
        #
        # @return [#call]
        #   The naming convention for the given Repository
        #
        # @api public
        def field_naming_convention
          @field_naming_convention ||= lambda { |property| property.name.to_s.underscore }
        end

        # @api private
        def properties_with_subclasses
          props = properties.dup

          descendants.each do |model|
            model.properties.each do |property|
              props << property
            end
          end

          props
        end

        # @api private
        def key_conditions(key)
          Hash[ self.key.zip(key.nil? ? [] : key) ]
        end

      private

        # Defines the anonymous module that is used to add properties.
        # Using a single module here prevents having a very large number
        # of anonymous modules, where each property has their own module.
        # @api private
        def property_module
          @property_module ||= begin
            mod = Module.new
            class_eval do
              include mod
            end
            mod
          end
        end

        def set_primary_key_for(property)
          if property.key? || property.serial?
            self.primary_key = property.name
          end
        end

        # defines the reader method for the property
        #
        # @api private
        def create_reader_for(property)
          return if property.key? || property.serial? # let AR do it
          name                   = property.name.to_s
          reader_visibility      = property.reader_visibility
          instance_variable_name = property.instance_variable_name
          property_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            #{reader_visibility}
            def #{name}
              attribute_get(#{name.inspect})
            end
          RUBY

          if property.kind_of?(Ardm::Property::Boolean)
            boolean_reader_name = "#{name}?"
            property_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
              #{reader_visibility}
              def #{boolean_reader_name}
                #{name}
              end
            RUBY
          end
        end

        # defines the setter for the property
        #
        # @api private
        def create_writer_for(property)
          return if property.key? || property.serial? # let AR do it
          name              = property.name
          writer_visibility = property.writer_visibility

          writer_name = "#{name}="
          property_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            #{writer_visibility}
            def #{writer_name}(value)
              attribute_set(#{name.inspect}, value)
            end
          RUBY
        end

        def add_validations_for(property)
          return if property.key? || property.serial?
          rules = Validation.rules_for_property(property)
          rules.each do |options|
            validates(property.name, options)
          end
        end

        # @api public
        #def method_missing(method, *args, &block)
        #  if property = properties[method]
        #    return property
        #  end

        #  super
        #end
      end # module ClassMethods
    end # module Rails
  end # class Property
end # module Ardm
