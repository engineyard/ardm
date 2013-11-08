require 'ardm/property/class'

module Ardm
  class Property
    class Discriminator < Class
      load_as   ::Class
      dump_as   ::String
      default   lambda { |resource, property| resource.class }
      required  true

      # ActiveRecord just stores the string name of the class.
      # We dump false for a bad value because it results in a
      # class that isn't in the "dump_as".
      #
      # Expects the class name to be a valid class name that is
      # loaded and available.
      def dump(value)
        dumped = typecast(value)
        dumped.name if dumped.is_a?(::Class)
      end

      def load(value)
        typecast(value)
      end

      # @api private
      def bind
        model.inheritance_column = field
        model.extend Model unless model < Model
      end

      module Model
        def inherited(model)
          super  # setup self.descendants
          #set_discriminator_scope_for(model)
        end

        def new(*args, &block)
          if args.size == 1 && args.first.kind_of?(Hash)
            discriminator = properties.discriminator

            if discriminator_value = args.first[discriminator.name]
              model = discriminator.typecast(discriminator_value)

              if model.kind_of?(Model) && !model.equal?(self)
                return model.new(*args, &block)
              end
            end
          end

          super
        end

      private

        def set_discriminator_scope_for(model)
          discriminator = self.properties.discriminator
          model.scoped.with_default_scope.update_all(discriminator.field => model.descendants.dup << model)
        rescue ::ActiveRecord::ConnectionNotEstablished => e
          puts "Error was raised but it seems to be an ActiveRecord 3.2 error, fixed in 4:\n#{e}"
        end
      end
    end # class Discriminator
  end # class Property
end # module Ardm
