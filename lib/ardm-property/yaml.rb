require 'yaml'
require 'ardm-property'
require 'ardm-property/support/dirty_minder'

module Ardm
  class Property
    class Yaml < Text
      load_as ::Object

      def load(value)
        if value.nil?
          nil
        elsif value.is_a?(::String)
          ::YAML.load(value)
        else
          raise ArgumentError, '+value+ of a property of YAML type must be nil or a String'
        end
      end

      def dump(value)
        if value.nil?
          nil
        elsif value.is_a?(::String) && value =~ /^---/
          value
        else
          ::YAML.dump(value)
        end
      end

      def typecast(value)
        value
      end

      include ::Ardm::Property::DirtyMinder

    end # class Yaml
  end # class Property
end # module Ardm
