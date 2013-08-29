require 'ardm-property/paranoid/base'

module Ardm
  class Property
    class ParanoidDateTime < DateTime
      lazy true

      # @api private
      def bind
        property_name = name.inspect

        model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          include Ardm::Property::Paranoid::Base

          set_paranoid_property(#{property_name}) { ::DateTime.now }

          default_scope { where(#{property_name} => nil) }
        RUBY
      end
    end # class ParanoidDateTime
  end # class Property
end # module Ardm
