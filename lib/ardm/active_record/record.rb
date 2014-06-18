require 'active_record'
require 'ardm'
require 'ardm/active_record/base'

module Ardm
  module ActiveRecord
    class Record < ::ActiveRecord::Base
      include Ardm::ActiveRecord::Base

      self.abstract_class = true

      class_attribute :raise_on_save_failure
      self.raise_on_save_failure = false

      JSON = Json

      class_attribute :on_finalize
      self.on_finalize = []

      def self.finalize
        on_finalize.each { |f| f.call }
      end

      def self.execute_sql(sql)
        connection.execute(sql)
      end

      def self.property(property_name, property_type, options={})
        property = super
        begin
        rescue => e
          puts "WARNING: Error silenced. FIXME before release.\n#{e}" unless $attr_accessible_warning
          $attr_accessible_warning = true
        end
        property
      end

      # no-op in active record
      def self.timestamps(*a)
      end

      def self.update(*a)
        options = dump_properties_hash(a.first)
        options = dump_associations_hash(options)
        assert_valid_attributes(options)
        update_all(options) != 0
      end

      def self.update!(*a)
        options = dump_properties_hash(a.first)
        options = dump_associations_hash(options)
        assert_valid_attributes(options)
        update_all(options) != 0
      end

      def self.destroy!(*a)
        delete_all
      end

      def new?
        new_record?
      end

      def saved?
        !new_record?
      end

      def save_self(*)
        save
      end

      def save
        super || (raise_on_save_failure && raise(Ardm::SaveFailureError, "Save Failed"))
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
