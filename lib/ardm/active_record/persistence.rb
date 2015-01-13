require 'active_support/concern'

module Ardm
  module ActiveRecord
    module Persistence
      extend ActiveSupport::Concern

      included do
        class_attribute :raise_on_save_failure, instance_accessor: true
        self.raise_on_save_failure = false
      end

      module ClassMethods
        def update(*a)
          options = dump_properties_hash(a.first)
          options = dump_associations_hash(options)
          assert_valid_attributes(options)
          update_all(options) != 0
        end

        def update!(*a)
          options = dump_properties_hash(a.first)
          options = dump_associations_hash(options)
          assert_valid_attributes(options)
          update_all(options) != 0
        end

        def destroy(*a)
          destroy_all
        end

        def destroy!(*a)
          delete_all
        end
      end

      def destroy
        self.class.delete(self.send(self.class.primary_key))
      end

      def new?
        new_record?
      end

      def saved?
        !new_record?
      end

      def save_self(execute_hooks = true)
        save(execute_hooks)
      end

      # @todo: be more like DM:
      # DM version of this method pasted here as a comment for your convenience
      # # short-circuit if the resource is not dirty
      # return saved? unless dirty_self?
      #
      # if execute_hooks
      #   new? ? create_with_hooks : update_with_hooks
      # else
      #   _persist
      # end
      # clean?
      def save(execute_hooks=true)
        unless execute_hooks
          raise Ardm::NotImplemented, "ActiveRecord doesn't support saving without callbacks"
        end

        super() # no args!
      end

      def save!(*args)
        save(*args) || (raise_on_save_failure && raise(Ardm::SaveFailureError, "Save Failed"))
      end

      def update(*a)
        if a.size == 1
          update_attributes(*a)
        else
          super
        end
      end

      def update!(*a)
        update_attributes!(*a)
      end
    end
  end
end
