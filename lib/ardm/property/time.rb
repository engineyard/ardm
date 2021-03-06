require 'ardm/property/object'

module Ardm
  class Property
    class Time < Object
      load_as         ::Time
      dump_as         ::Time
      coercion_method :to_time

    end # class Time
  end # class Property
end # module Ardm
