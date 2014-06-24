module Ardm
  module Query
    class Expression
      attr_reader :relation, :target, :operator, :value

      def self.build_scope(relation, target, value)
        new(relation, target, value).scope
      end

      def initialize(relation, target, operator, value)
        @relation   = relation
        @value      = value
        @operator   = operator
        @target     = target
      end

      def resolved_target
        target_from_association || target
      end

      def arel_target
        arel_table[resolved_target]
      end

      def to_arel
        arel_target.send(arel_operator, arel_value)
      end

      def scope
        relation.where to_arel
      end

      private

      def arel_table
        relation.arel_table
      end

      def association
        @association ||= relation.reflect_on_association(target)
      end

      def target_from_association
        if association
          if association.macro == :belongs_to
            association.foreign_key.to_sym
          else
            $stderr.puts "WARNING: #{association.macro} based queries not yet supported?"
            association.primary_key.to_sym
          end
        end
      end

      def arel_operator
        value.respond_to?(:to_ary) ? operator.for_array : operator
      end

      def arel_value(val = value)
        if val.respond_to?(:to_ary)
          return val.map {|v| arel_value(v) }
        end

        case val
        when ::ActiveRecord::Base
          val.id
        when ::ActiveRecord::Relation
          arel_value(val.to_ary)
        when ::Array
          val.map {|v| arel_value(v) }
        else
          val
        end
      end
    end
  end
end
