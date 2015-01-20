module Ardm
  module Ar
    module Dirty
      def dirty?
        changed?
      end

      def dirty_attributes
        changes.inject({}) do |memo, (attr, val)|
          property = properties[attr]
          memo[property] = val
          memo
        end
      end

      def method_missing(meth, *args, &block)
        if meth.to_s =~ /^([\w_]+)_dirty\?$/
          send("#{$1}_changed?", *args, &block)
        else
          super
        end
      end
    end
  end
end
