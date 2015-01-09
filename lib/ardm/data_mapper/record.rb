require 'active_support/concern'
require 'dm-core'
require 'ardm/data_mapper/collection'

module Ardm
  module DataMapper
    class Record
      def self.inherited(base)
        base.send(:include, ::DataMapper::Resource)
      end

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
