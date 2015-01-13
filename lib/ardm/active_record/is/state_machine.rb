module Ardm
  module ActiveRecord
    module Is
      module StateMachine
        extend ActiveSupport::Concern

        included do
          if defined?(AASM)
            include AASM
          end
        end

        module ClassMethods
          def is_state_machine(options, &block)
            unless defined?(AASM)
              STDERR.puts "WARNING: you need to load AASM yourself (not ardm gemspec)"
            end
            STDERR.puts "TODO: dm state machine on #{self}"
            property options[:column], Ardm::Property::String, default: options[:initial]
            aasm column: options[:column], &block
          end
        end
      end
    end
  end
end
