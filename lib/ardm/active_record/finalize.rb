module Ardm
  module ActiveRecord
    module Finalize
      extend ActiveSupport::Concern

      def self.on_finalize(&block)
        @on_finalize ||= []
        @on_finalize << block if block_given?
        @on_finalize
      end

      module ClassMethods
        def finalize
          Ardm::ActiveRecord::Finalize.on_finalize.each { |f| f.call }
        end
      end
    end
  end
end
