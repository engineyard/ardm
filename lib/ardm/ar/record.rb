require 'active_record'
require 'ardm'
require 'ardm/ar/base'

module Ardm
  module Ar
    class Record < ::ActiveRecord::Base
      include Ardm::Ar::Base

      self.abstract_class = true

      def self.property(property_name, property_type, options={})
        prop = super
        begin
          attr_accessible prop.name
          attr_accessible prop.field
        rescue => e
          puts "WARNING: `attr_accessible` not found. Include 'protected_attributes' gem in rails >= 4 (if you need it).\n#{e}" unless $attr_accessible_warning
          $attr_accessible_warning = true
        end
        prop
      end
    end
  end
end
