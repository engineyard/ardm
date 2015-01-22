require 'active_support/concern'
require 'dm-core'
require 'ardm/dm/collection'

module Ardm
  module Dm
    class Record
      def self.inherited(base)
        @on_inherited.each { |block| base.class_eval(&block) }
      end

      def self.on_inherited(&block)
        if Ardm::Dm::Record == self
          @on_inherited ||= []
          @on_inherited << block
          @on_inherited
        else
          class_eval(&block)
        end
      end

      class << self
        alias __include_after_inherited__ include
      end

      def self.include(mod)
        on_inherited { __include_after_inherited__ mod }
      end

      include ::DataMapper::Resource

      def self.finalize
        ::DataMapper.finalize
      end

      def self.repository(*args, &block)
        ::DataMapper.repository(*args, &block)
      end

      def self.logger
        ::DataMapper.logger
      end

      def self.logger=(logger)
        ::DataMapper.logger = logger
      end

      def self.alias_attribute(new, old)
        alias_method new, old
      end

      def self.attr_accessible(*attrs)
      end

      def self.abstract_class=(val)
      end

      def self.table_name=(name)
        self.storage_names[:default] = name
      end
    end
  end
end
