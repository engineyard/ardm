require 'active_support/concern'

module Ardm
  class Property
    module Flags
      extend ActiveSupport::Concern

      included do
        accept_options :flags
        attr_reader :flag_map

        class << self
          attr_accessor :generated_classes
        end

        self.generated_classes = {}
      end

      def custom?
        true
      end

      module ClassMethods
        # TODO: document
        # @api public
        def [](*values)
          if klass = generated_classes[values.flatten]
            klass
          else
            klass = ::Class.new(self)
            klass.flags(values)

            generated_classes[values.flatten] = klass

            klass
          end
        end
      end
    end
  end
end
