module Ardm
  module ActiveRecord
    module PredicateBuilder
      class ArrayHandler # :nodoc:
        def call(attribute, value)
          if value.include?(nil)
            values = value.compact
            if values.length == 0
              attribute.eq(nil)
            else
              call(attribute, values).or(attribute.eq(nil))
            end
          else
            values = value.map { |x| x.is_a?(::ActiveRecord::Base) ? x.id : x }
            ranges, values = values.partition { |v| v.is_a?(::Range) }

            array_predicates = ranges.map { |range| attribute.in(range) }
            array_predicates << attribute.in(values)
            array_predicates.inject { |composite, predicate| composite.or(predicate) }
          end
        end
      end
    end
  end
end
