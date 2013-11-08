require 'pathname'
require 'ardm/property/string'

module Ardm
  class Property
    class FilePath < String
      load_as Pathname

      length 255

      def load(value)
        Pathname.new(value) unless Ardm::Ext.blank?(value)
      end

      def dump(value)
        value.to_s unless Ardm::Ext.blank?(value)
      end

      def typecast(value)
        load(value)
      end

    end # class FilePath
  end # class Property
end # module Ardm
