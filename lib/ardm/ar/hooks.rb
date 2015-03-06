require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module Ardm
  module Ar
    module Hooks
      extend ActiveSupport::Concern

      # For each class that defines custom hooks (i.e. not :save, :create, :destroy, etc),
      # store the names of these custom hooks in an array
      # as a class variable (@@methods_to_redefine) of that class.
      #
      # This is used to figure out which methods to redefine should they
      # get defined after the callback method is defined.
      # This allows us to wrap the original methods with `run_callbacks`.

      included do
        self.instance_eval do
          def method_added(name)
            if (self.class_variable_defined?(:@@methods_to_redefine) &&
                self.methods_to_redefine && self.methods_to_redefine.include?(name))

              self._redefine_original_method(name)
            end
          end
        end
      end

      module ClassMethods
        def before(event, meth=nil, &block)
          _ardm_hook(:before, event, meth, &block)
        end

        def after(event, meth=nil, &block)
          _ardm_hook(:after, event, meth, &block)
        end

        def _ardm_hook(order, event, meth=nil, &block)
          if event.to_sym == :valid?
            event = "validation"
          end

          callback_name = "#{order}_#{event}".to_sym
          if !ActiveRecord::Callbacks::CALLBACKS.include?(callback_name)
            _define_callbacks_and_wrap_original_method(event.to_sym)
          end

          if meth.nil?
            send callback_name, &block
          else
            send callback_name, meth
          end
        end

        def _redefine_original_method(name)
          self.class_eval do
            if method_defined?(name) && instance_method(name) != instance_method(_callbacks_method(name))
              alias_method _original_method(name), name
              alias_method name, _callbacks_method(name)
            end
          end
        end

        def _callbacks_method(name)
          "_with_callbacks_#{name}".to_sym
        end

        def _original_method(name)
          "_original_#{name}".to_sym
        end

        def _define_method_with_callbacks(name)
          self.class_eval do
            unless method_defined?(_callbacks_method(name))
              define_method(_callbacks_method(name)) do |*args|
                run_callbacks(name) do
                  self.send(self.class._original_method(name), *args)
                end
              end
            end
          end
        end

        def _define_callbacks_and_wrap_original_method(name)
          if !self.class_variable_defined?(:@@methods_to_redefine)
            self.class_eval do
              mattr_accessor :methods_to_redefine
              self.methods_to_redefine = []
            end
          end
          self.methods_to_redefine << name

          self.class_eval { define_model_callbacks name }
          _define_method_with_callbacks(name)
          _redefine_original_method(name)
        end
      end
    end
  end
end
