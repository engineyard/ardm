require 'ardm/property/string'

module Ardm
  class Property
    class Text < String
      length 65535
      lazy   true

    end # class Text
  end # class Property
end # module Ardm
