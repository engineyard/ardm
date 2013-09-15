module Ardm
  class Property
    module Rails
      module QueryMethods
        #def build_where(opts, other = [])
        #  if Hash === opts
        #    puts "#{klass}.build_where(#{opts.inspect})"
        #    new_attributes = opts.inject({}) do |memo, (k, v)|
        #      property = klass.properties[k] or raise("unknown property #{k}")
        #      memo[property.field] = property.dump(v)
        #      memo
        #    end
        #    puts "#{klass}.build_where(#{new_attributes.inspect})"
        #    super new_attributes, other
        #  else
        #    super
        #  end
        #end
      end

      module ActiveRecordFinderMethods
      end # module ActiveRecordFinderMethods
    end # module Rails
  end # class Property
end # module Ardm
