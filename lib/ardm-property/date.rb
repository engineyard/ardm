module Ardm
  class Property
    class Date < Object
      load_as         ::Date
      dump_as         ::Date
      coercion_method :to_date

    end # class Date
  end # class Property
end # module Ardm
