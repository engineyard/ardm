module Ardm
  class Property
    module Rails
      module ActiveRecordInstanceMethods

        # when exactly does a datamapper default property get set?
        def initialize_ardm_property_defaults
          return unless new_record?
          self.class.properties.each do |property|
            name = property.name
            value = property.default

            next if value.nil?
            next unless read_attribute(name).nil?

            if Proc === value
              write_attribute(name, value.to_proc.call(self, name))
            else
              write_attribute(name, value)
            end
          end
        end

        def assign_attributes(*a)
          #binding.pry
          super
        end

        def type_cast_attribute_for_write(column, value)
          if column && property = properties[column.name]
            property.dump(value)
          else
            super
          end
        end

        def _field_changed?(attr, old, value)
          if properties[attr.to_sym]
            old != value
          else
            super
          end
        end

        def read_attribute(attr_name)
          property = properties[attr_name]
          property ||= properties.detect { |p| p.field == attr_name.to_s }
          name = property.field
          @attributes_cache[name] || @attributes_cache.fetch(name) {
            value = @attributes.fetch(name) {
              return block_given? ? yield(name) : nil
            }

            if self.class.cache_attribute?(name)
              @attributes_cache[name] = property.load(value)
            else
              property.load value
            end
          }
        end

        def write_attribute(attr_name, value)
          attr_name = attr_name.to_s
          attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key

          if property = properties[attr_name]
            attr_name = property.field
          end

          @attributes_cache.delete(attr_name)

          column = column_for_attribute(attr_name)
          if property && !column
            binding.pry
          end

          if column || property || @attributes.has_key?(attr_name)
            @attributes[property.field] = property.dump(value)
          else
            raise ActiveModel::MissingAttributeError, "can't write unknown attribute `#{attr_name}'"
          end
        end

        # Real version (something isn't right with above)
        #
        #def write_attribute(attr_name, value)
        #  attr_name = attr_name.to_s
        #  attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key
        #  @attributes_cache.delete(attr_name)
        #  column = column_for_attribute(attr_name)

        #  # If we're dealing with a binary column, write the data to the cache
        #  # so we don't attempt to typecast multiple times.
        #  if column && column.binary?
        #    @attributes_cache[attr_name] = value
        #  end

        #  if column || @attributes.has_key?(attr_name)
        #    @attributes[attr_name] = type_cast_attribute_for_write(column, value)
        #  else
        #    raise ActiveModel::MissingAttributeError, "can't write unknown attribute `#{attr_name}'"
        #  end
        #end

        def read_attribute_before_type_cast(attr_name)
          property = properties[attr_name]
          property.dump(super)
        end

        def attributes_before_type_cast
          super.dup.tap do |attributes|
            properties.each do |property|
              if attributes.key?(property.field)
                attributes[property.field] = property.dump(attributes[property.field])
              end
            end
          end
        end

        def typecasted_attribute_value(name)
          #property = properties[name]
          #property.load(@attributes[property.field])
          super
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
