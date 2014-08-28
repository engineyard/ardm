module Ardm
  module ActiveRecord
    module Finalize
      extend ActiveSupport::Concern

      included do
        class_attribute :on_finalize
        self.on_finalize = []
      end

      module ClassMethods
        def finalize
          on_finalize.each { |f| f.call }
        end
      end
    end
  end
end
