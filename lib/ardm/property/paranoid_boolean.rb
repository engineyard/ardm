require 'ardm/property/boolean'
require 'ardm/property/support/paranoid_base'

module Ardm
  class Property
    class ParanoidBoolean < Boolean
      default false
      lazy    true

      # @api private
      def bind
        model.send(:include, Ardm::Property::ParanoidBase)
        model.set_paranoid_property(name) { true }
        model.set_paranoid_scope(model.arel_table[name].eq(false))
      end
    end # class ParanoidBoolean
  end # class Property
end # module Ardm
