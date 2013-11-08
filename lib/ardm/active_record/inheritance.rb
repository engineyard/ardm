require 'active_support/concern'

module Ardm
  module ActiveRecord
    module Inheritance
      extend ActiveSupport::Concern

      included do
        # ActiveRecord would prefer that you not use the column "type"
        # for anything other than single table inheritance.
        # The solution is to point ActiveRecord elsewhere.
        unless respond_to?(:inheritance_column=)
          class_attribute :inheritance_column
        end
        self.inheritance_column = "override-active-record-default-sti-column-type"
      end

      module ClassMethods
        def new(attrs={}, *a, &b)
          type = attrs && attrs.stringify_keys[inheritance_column.to_s]
          if type && type != name && type != self
            #puts "STI found for #{type} #{self}"
            con = type.is_a?(Class) ? type : type.constantize
            if con < self
              con.new(attrs, *a, &b)
            else
              raise "Tried to create subclass from #{type} (from key #{inheritance_column}) that is not a subclass of #{name}."
            end
          else
            #puts "No STI found for #{self} (#{attrs.inspect})"
            super
          end
        end
      end
    end
  end
end
