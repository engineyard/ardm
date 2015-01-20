module Ardm
  module Ar
    module Is
      module StateMachine
        extend ActiveSupport::Concern

        included do
          include AASM
        end

        module ClassMethods
          def is_state_machine(options, &block)
            STDERR.puts "TODO: dm state machine on #{self}"
            property options[:column], Ardm::Property::String, default: options[:initial]
            aasm column: options[:column], &block
          end
        end
      end
    end
  end
end
