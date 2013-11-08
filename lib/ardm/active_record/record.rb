require 'active_record'
require 'ardm'
require 'ardm/active_record/base'

module Ardm
  module ActiveRecord
    class Record < ::ActiveRecord::Base
      include Ardm::ActiveRecord::Base

      self.abstract_class = true

      JSON = Json

      def self.finalize
      end

      def self.execute_sql(sql)
        connection.execute(sql)
      end

      def self.property(property_name, property_type, options={})
        property = super
        begin
        attr_accessible property.name
        attr_accessible property.field
        rescue => e
          puts "WARNING: Error silenced. FIXME before release.\n#{e}"
        end
        property
      end

      # no-op in active record
      def self.timestamps(*a)
      end

      def key
        id
      end

      def new?
        new_record?
      end

      def save_self(*)
        save
      end

      def update(*a)
        if a.size == 1
          update_attributes(*a)
        else
          super
        end
      end

      def update!(*a)
        update_attributes!(*a)
      end

      #active record internals for detecting if this method should exist as an attribute
      #if attribute_method_matcher(:open)
      #  def open
      #    read_attribute(:open)
      #    #attribute_missing(match, *args, &block)
      #  end
      #end

    end
  end
end
