module Ardm
  class Property
    class Serial < Integer
      serial true
      min    1

      # @api private
      def to_child_key
        Property::Integer
      end

    end # class Text
  end # class Property
end # module Ardm
