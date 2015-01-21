module Ardm
  module Ar
    module Finalize
      extend ActiveSupport::Concern

      def self.finalizers
        @finalizers ||= []
      end

      def self.on_finalize(&block)
        return unless block_given?
        finalizers << block
      end

      def self.finalize
        Ardm::Ar::Finalize.finalizers.each { |f| f.call }
      end

      module ClassMethods
        def finalize
          Ardm::Ar::Finalize.finalize
        end
      end
    end
  end
end
