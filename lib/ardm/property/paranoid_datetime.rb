require 'ardm/property/datetime'
require 'ardm/property/support/paranoid_base'

module Ardm
  class Property
    class ParanoidDateTime < DateTime
      lazy true

      # @api private
      def bind
        model.send(:include, Ardm::Property::ParanoidBase)
        model.set_paranoid_property(name) { ::DateTime.now }
        model.set_paranoid_scope(model.arel_table[name].eq(nil))
      end
    end # class ParanoidDateTime
  end # class Property
end # module Ardm
