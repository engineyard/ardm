require 'ardm-property/paranoid/base'

module Ardm
  class Property
    class ParanoidBoolean < Boolean
      default false
      lazy    true

      # @api private
      def bind
        property_name = name.inspect

        model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          include Ardm::Property::Paranoid::Base

          set_paranoid_property(#{property_name}) { true }

          default_scope { where(#{property_name} => false) }
        RUBY
      end
    end # class ParanoidBoolean
  end # class Property
end # module Ardm
