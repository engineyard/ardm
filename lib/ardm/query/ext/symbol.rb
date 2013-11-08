require 'ardm/query/operator'

module Ardm
  module Query
    module Ext
      module Symbol
        Ardm::Query::Operator::OPERATORS.each do |dm, arel|
          define_method dm do
            Ardm::Query::Operator.new(self, arel)
          end
          #class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #  def #{dm}
          #    #{"raise \"explicit use of '#{dm}' operator is deprecated (#{caller.first})\"" if dm == :eql || dm == :in}
          #    Ardm::Query::Operator.new(self, #{arel.inspect})
          #  end
          #RUBY
        end

        # FIXME: handle aliased columns
        # It's easier to turn these into strings for now,
        # but I think it will break for aliased columns.
        Ardm::Query::Operator::ORDERS.each do |dm, arel|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{dm}
              "\#{self} #{arel.upcase}"
            end
          RUBY
        end
      end
    end
  end
end

class ::Symbol
  Ardm::Query::Operator::ALL.keys.each { |meth| method_defined?(meth) && remove_method(meth) }
  include Ardm::Query::Ext::Symbol
end # class Symbol
