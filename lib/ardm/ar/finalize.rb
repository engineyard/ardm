module Ardm
  module Ar
    module Finalize
      extend ActiveSupport::Concern

      def self.on_finalize(&block)
        @on_finalize ||= []
        @on_finalize << block if block_given?
        @on_finalize
      end

      module ClassMethods
        def finalize
          Ardm::Ar::Finalize.on_finalize.each { |f| f.call }
        end
      end
    end
  end
end
