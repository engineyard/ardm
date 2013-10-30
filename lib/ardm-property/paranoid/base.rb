module Ardm
  class Property
    module Paranoid
      module Base
        def self.included(model)
          model.extend ClassMethods
          model.instance_variable_set(:@paranoid_properties, {})
        end

        def paranoid_destroy
          self.class.paranoid_properties.each do |name, block|
            attribute_set(name, block.call(self))
          end
          save
          @readonly = true
          true
        end

        def destroy(execute_hooks = true)
          # NOTE: changed behavior because AR doesn't call hooks on destroying new objects
          return false if new_record?
          if execute_hooks
            run_callbacks :destroy do
              paranoid_destroy
            end
          else
            super
          end
        end

      end # module Base

      module ClassMethods
        def inherited(model)
          model.instance_variable_set(:@paranoid_properties, @paranoid_properties.dup)
          super
        end

        # @api public
        def with_deleted(&block)
          with_deleted_scope = self.scoped.with_default_scope
          paranoid_properties.keys.each do |property_name|
            with_deleted_scope.unscope(:where => property_name)
          end
          with_deleted_scope.scoped { block_given? ? yield : all }
        end

        # @api private
        def paranoid_properties
          @paranoid_properties
        end

        # @api private
        def set_paranoid_property(name, &block)
          paranoid_properties[name] = block
        end

        def set_paranoid_scope(conditions)
          default_scope { where(conditions) }
        end
      end # module ClassMethods
    end # module Paranoid
  end # class Property
end # module Ardm
