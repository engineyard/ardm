#require 'active_record'
#
module Ardm
  class Property
    module Rails
      module ClassMethods
        def self.extended(model)
          model.instance_variable_set(:@properties,               PropertySet.new)
          model.instance_variable_set(:@field_naming_conventions, {})
          model.send :after_initialize, :initialize_ardm_property_defaults

          super
        end

        def inherited(model)
          model.instance_variable_set(:@properties,               PropertySet.new)
          model.instance_variable_set(:@field_naming_conventions, @field_naming_conventions.dup)

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

          create_reader_for(property)
          create_writer_for(property)

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
          @field_naming_conventions ||= connection.adapter.field_naming_convention
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
              return #{instance_variable_name} if defined?(#{instance_variable_name})
              property = self.class.properties[#{name.inspect}]
              #{instance_variable_name} = property ? read_attribute(property.name) : nil
            end
          RUBY

          boolean_reader_name = "#{name}?"

          if property.kind_of?(Ardm::Property::Boolean)
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
              property = self.class.properties[#{name.inspect}]
              write_attribute(property.name, value)
              read_attribute(property.name)
            end
          RUBY
        end

        # @api public
        def method_missing(method, *args, &block)
          if property = properties[method]
            return property
          end

          super
        end
      end # module ClassMethods

      module InstanceMethods

        def initialize_ardm_property_defaults
          #noted skepticism: when exactly does a datamapper default property get set?
          return unless new_record?
          self.class.properties.each do |property|
            attr = property.name
            value = property.default
            next if value.nil?
            if self.respond_to?(attr)
              if self.method(attr).arity != 0
                puts "Couldn't initialize #{attr} with #{value} on #{self}"
                next
              end
            end
            next unless read_attribute(attr).nil?
            if Proc === value
              send("#{attr}=", value.to_proc.call(self, attr))
            else
              send("#{attr}=", value)
            end
          end
        end

        # This not the same as read_attribute in AR
        def attribute_get(name)
          send name
        end

        # This not the same as write_attribute in AR
        def attribute_set(name, value)
          send "#{name}=", value
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

      end # module InstanceMethods
    end # module Rails
  end # class Property
end # module Ardm

ActiveRecord::Base.extend Ardm::Property::Rails::ClassMethods
ActiveRecord::Base.send :include, Ardm::Property::Rails::InstanceMethods
ActiveRecord::Base.extend Ardm::Property::Lookup
