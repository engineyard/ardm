require 'ardm/property/string'
require 'ardm/property/support/dirty_minder'

if RUBY_VERSION >= '1.9.0'
  require 'csv'
else
  require 'fastercsv'  # must be ~>1.5
  CSV = FasterCSV unless defined?(CSV)
end

module Ardm
  class Property
    class Csv < String
      load_as ::Array

      def load(value)
        case value
        when ::String then CSV.parse(value)
        when ::Array  then value
        end
      end

      def dump(value)
        case value
          when ::Array
            CSV.generate { |csv| value.each { |row| csv << row } }
          when ::String then value
        end
      end

      include ::Ardm::Property::DirtyMinder

    end # class Csv
  end # class Property
end # module Ardm
