require 'active_support/concern'

require 'ardm/query/expression'
require 'ardm/query/operator'
require 'ardm/query/ext/symbol'
require 'ardm/active_record/predicate_builder'

module Ardm
  module ActiveRecord
    module Query
      extend ActiveSupport::Concern

      def self.order(model, ord)
        case ord
        when Array
          ord.map {|o| order(model, o) }.join(", ")
        when Ardm::Query::Operator
          field = ord.target
          if property = model.properties[field]
            field = property.field
          end
          "#{field} #{ord.operator.upcase}"
        else
          ord
        end
      end

      module ClassMethods
        def execute_sql(sql)
          connection.execute(sql)
        end

        # hook into query engine in the most general way possible
        def expand_hash_conditions_for_aggregates(options)
          complex, simple = options.partition {|k,v| Ardm::Query::Operator === k }
          result = super(Hash[simple]) # send simple all at once to save computation
          complex.each do |(operator, value)|
            expanded_opts = super(operator.target => value)

            if expanded_opts.size > 1
              $stderr.puts "WARNING: Operator #{operator.target.inspect} on multiple attribute aggregate #{expanded_opts.inspect} might be totally crazyballs."
            end

            expanded_opts.each do |new_key, new_val|
              new_operator = Ardm::Query::Operator.new(new_key, operator.operator)
              result[new_operator] = new_val
            end
          end

          # This hack allows access to the original class from within the PredicateBuilder (so hax)
          class << result
            attr_accessor :klass
          end
          result.klass = self
          result
        end

        def get(id)
          if Array === id && id.size == 1
            # Model#key returns an array
            id = id.first
          end
          where(primary_key => id).first
        end

        def get!(id)
          if Array === id && id.size == 1
            # Model#key returns an array
            id = id.first
          end
          find(id)
        end

        def first_or_create(find_params)
          all(find_params).first_or_create
        end

        def first_or_create!(find_params)
          all(find_params).first_or_create!
        end

        def first_or_initialize(find_params)
          all(find_params).first_or_initialize
        end

        #def exist?(options={})
        #  puts "#{self}.exist?(#{options.inspect})"
        #  puts caller[0..10]
        #  options.empty? ? super : all(options).exist?
        #end

        #def count(options={})
        #  puts "#{self}.count(#{options.inspect})"
        #  puts caller[0..10]
        #  $visited ||= 0
        #  puts $visited += 1
        #  raise if $visited > 10
        #  options.empty? ? super : all(options).count
        #end
      end
    end
  end
end
