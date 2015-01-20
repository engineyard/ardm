require 'active_support/concern'

module Ardm
  module Ar
    module Hooks
      extend ActiveSupport::Concern

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

          if meth.nil?
            send "#{order}_#{event}", &block
          else
            send "#{order}_#{event}", meth
          end
        end
      end
    end
  end
end
