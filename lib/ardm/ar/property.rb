require 'active_support/concern'
require 'ardm/property/lookup'

module Ardm
  module Ar
    module Property
      extend ActiveSupport::Concern

      included do
        extend Ardm::Property::Lookup
        extend Ardm::Ar::Property::ClassMethods

        instance_variable_set(:@properties, Ardm::PropertySet.new)
        instance_variable_set(:@field_naming_convention, nil)
        send :before_validation, :initialize_ardm_property_defaults
      end

      def self.extended(model)
        raise "Please include #{self} instead of extend."
      end

      module ClassMethods

        def inherited(model)
          model.instance_variable_set(:@properties, Ardm::PropertySet.new)
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

          if !klass || klass == NilClass
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

        def timestamps(at=:at)
          case at
          when :at
            property :created_at, DateTime
            property :updated_at, DateTime
          when :on
            property :created_on, Date
            property :updated_on, Date
          else
            raise ArgumentError, "Unknown argument: timestamps(#{at.inspect})"
          end
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
          @columns ||= _ardm_load_columns(super)
        end

        def _ardm_load_columns(ar_columns)
          to_return = ar_columns
          properties.each do |property|
            sql_type = connection.type_to_sql(
              property.dump_as.name.to_sym,
              property.options[:limit],
              property.options[:precision],
              property.options[:scale]
            )
            if column = ar_columns.detect{|c| c.name.to_s == property.name.to_s}
              #TODO: property.key?
              err_prefix = "WARNING: DM/AR mismatch for #{self.name}.#{property.name.to_s} on"

              #TODO: do some fuzzy matching so we only get warnings when there is a clear conflict:
              # if column.sql_type != sql_type
              # puts "#{err_prefix} sql_type #{sql_type} vs #{column.sql_type}"
              # end

              if column.null != property.allow_nil?
                puts "#{err_prefix} allow_nil #{property.allow_nil?} vs #{column.null}"
              end

              #TODO: is this needed, or does default-setting get handled elsewhere?
              # if column.default != property.default
              #   puts "#{err_prefix} default #{property.default} vs #{column.default}"
              # end
              # column.default = property.default

            else
              puts "WARNING: DM defines property #{self.name}.#{property.name.to_s} but AR found no corresponding column"
            end
          end
          to_return

          # WAS:
          # sql_type = connection.type_to_sql(
          #   property.dump_as.name.to_sym,
          #   property.options[:limit],
          #   property.options[:precision],
          #   property.options[:scale]
          # )
          #
          # column = ::ActiveRecord::ConnectionAdapters::Column.new(
          #   property.field.to_s, #property.name.to_s, #name
          #   nil,#property.dump(property.default), #default
          #   property.cast_type,
          #   sql_type, #sql_type
          #   property.allow_nil? #null
          # )
          #
          # column.primary = property.key?
          # column
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

        def assert_valid_attributes(options)
          options.each do |key, value|
            property = properties[key]
            property.assert_valid_value(value)
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
            self.primary_key ||= property.name
          end
        end

        # defines the reader method for the property
        #
        # @api private
        def create_reader_for(property)
          return if property.key? || property.serial? # let AR do it
          name                   = property.name.to_s
          reader_visibility      = property.reader_visibility
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
              attribute_set(:#{name}, value)
            end
          RUBY
        end

        def add_validations_for(property)
          return if property.key? || property.serial?
          rules = Ardm::Property::Validation.rules_for_property(property)
          rules.each do |options|
            validates(property.name, options)
          end
        end

        # @api public
        # This confuses the rails
        #
        #def method_missing(method, *args, &block)
        #  if property = properties[method]
        #    return property
        #  end

        #  super
        #end
      end # module ClassMethods

      # when exactly does a datamapper default property get set?
      def initialize_ardm_property_defaults
        return unless new_record?
        self.class.properties.each do |property|
          attribute_get(property.name) # assigns default on fetch
        end
        true
      end

      # This not the same as read_attribute in AR
      def attribute_get(name)
        if property = self.class.properties[name]
          val = read_attribute property.field
          if new_record? && val.nil? && property.default?
            write_attribute property.field, property.typecast(property.default_for(self))
          end
          read_attribute property.field
        end
      rescue => e
        puts "ERROR on attribute_get #{self.class.name}.#{name}"
        raise e
      end

      # This not the same as write_attribute in AR
      def attribute_set(name, value)
        if property = self.class.properties[name]
          write_attribute property.field, property.typecast(value)
          read_attribute property.field
        end
      end

      def assign_attributes(attrs, *a)
        new_attrs = attrs.inject({}) do |memo,(name,value)|
          if property = self.class.properties[name]
            memo[property.field] = property.typecast(value)
          else
            memo[name] = value
          end
          memo
        end
        super new_attrs, *a
      end

      # Retrieve the key(s) for this resource.
      #
      # This always returns the persisted key value,
      # even if the key is changed and not yet persisted.
      # This is done so all relations still work.
      #
      # @return [Array(Key)]
      #   the key(s) identifying this resource
      #
      # @api public
      def key
        return @_key if defined?(@_key)

        model_key = self.class.key

        key = model_key.map do |property|
          changed_attributes[property.name] || (property.loaded?(self) ? property.get!(self) : nil)
        end

        # only memoize a valid key
        @_key = key if model_key.valid?(key)

        key
      end

      # Gets this instance's Model's properties
      #
      # @return [PropertySet]
      #   List of this Resource's Model's properties
      #
      # @api private
      def properties
        self.class.properties
      end

      # Fetches all the names of the attributes that have been loaded,
      # even if they are lazy but have been called
      #
      # @return [Array<Property>]
      #   names of attributes that have been loaded
      #
      # @api private
      def fields
        properties.select do |property|
          property.loaded?(self) || (new_record? && property.default?)
        end
      end

      # Reset the key to the original value
      #
      # @return [undefined]
      #
      # @api private
      def reset_key
        properties.key.zip(key) do |property, value|
          property.set!(self, value)
        end
      end

    end # module Property
  end # module Rails
end # module Ardm
