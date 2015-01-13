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
        def on_finalize(&block)
          block.call if @finalized
          Ardm::ActiveRecord::Finalize.on_finalize << block
        end

        def finalize
          @finalized = true
          Ardm::ActiveRecord::Finalize.on_finalize.each { |f| f.call }
        end
      end
    end
  end
end
