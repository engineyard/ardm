require 'active_support/concern'
require 'ardm/ar/is/state_machine'

module Ardm
  module Ar
    module Is
      extend ActiveSupport::Concern

      module ClassMethods
        def is(target, options={}, &block)
          case target
          when :state_machine
            include Ardm::Ar::Is::StateMachine
            is_state_machine(options, &block)
          else
            STDERR.puts "TODO: #{self} is #{target.inspect}, #{options.inspect}"
          end
        end
      end
    end
  end
end
