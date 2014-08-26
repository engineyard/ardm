require 'active_support/concern'
require 'dm-core'

module Ardm
  module DataMapper
    class Record
      extend Forwardable

      def self.inherited(base)
        base.send(:include, ::DataMapper::Resource)
      end

      def self.finalize
        ::DataMapper.finalize
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
