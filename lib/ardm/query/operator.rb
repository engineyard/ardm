require 'ardm/support/equalizer'
module Ardm
  module Query
    class Operator
      extend Ardm::Equalizer

      OPERATORS = {
        # DM      => ARel
        :eql      => :eq,
        :not      => :not_eq,
        :in       => :in,
        :gt       => :gt,
        :gte      => :gteq,
        :lt       => :lt,
        :lte      => :lteq,
        :like     => :matches,
        :not_like => :does_not_match,
        :regexp   => :regexp,
      }

      ORDERS = {
        :asc  => :asc,
        :desc => :desc,
      }

      ALL = OPERATORS.merge(ORDERS)

      equalize :target, :operator

      # @api private
      attr_reader :target

      # @api private
      attr_reader :operator

      # @api private
      def inspect
        "#<#{self.class.name} #{target.inspect}.#{operator.inspect}>"
      end

      FOR_ARRAY = {
        :eq     => :in,
        :not_eq => :not_in
      }.freeze

      def for_array
        FOR_ARRAY[operator]
      end

      def to_arel(relation, value)
        Ardm::Query::Expression.new(relation, target, operator, value)
      end

      private

      # @api private
      def initialize(target, operator)
        @target, @operator = target, operator.to_sym
      end
    end # class Operator
  end # module Query
end # module Ardm

require 'ardm/query/ext/symbol'
