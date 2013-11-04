module Ardm
  class Property
    module Rails
      module ActiveRecordInstanceMethods

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
          property = self.class.properties[name]
          val = read_attribute property.field
          if new_record? && val.nil? && property.default?
            write_attribute property.field, property.typecast(property.default_for(self))
          end
          read_attribute property.field
        end

        # This not the same as write_attribute in AR
        def attribute_set(name, value)
          property = self.class.properties[name]
          write_attribute property.field, property.typecast(value)
          read_attribute property.field
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
