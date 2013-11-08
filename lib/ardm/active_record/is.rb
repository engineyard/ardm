require 'active_support/concern'
require 'ardm/active_record/is/state_machine'

module Ardm
  module ActiveRecord
    module Is
      extend ActiveSupport::Concern

      module ClassMethods
        def is(target, options={}, &block)
          case target
          when :state_machine
            include Ardm::ActiveRecord::Is::StateMachine
            is_state_machine(options, &block)
          else
            STDERR.puts "TODO: #{self} is #{target.inspect}, #{options.inspect}"
          end
        end
      end
    end
  end
end
