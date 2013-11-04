module Ardm
  class Property
    class Boolean < Object
      load_as         ::TrueClass
      dump_as         ::TrueClass
      coercion_method :to_boolean

      def initialize(model, name, options = {})
        # validates presence in rails fails for false.
        # Boolean must therefore behave like a set.
        options[:set] = [true, false]
        super model, name, options
      end

      # @api semipublic
      def value_dumped?(value)
        value_loaded?(value)
      end

      # @api semipublic
      def value_loaded?(value)
        value == true || value == false
      end

    end # class Boolean
  end # class Property
end # module Ardm
