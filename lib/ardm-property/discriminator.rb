module Ardm
  class Property
    class Discriminator < Class
      default   lambda { |resource, property| resource.class }
      required  true

      # @api private
      def bind
        model.inheritance_column = field
      end

      module Model
        def inherited(model)
          super  # setup self.descendants
          set_discriminator_scope_for(model)
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
          model.unscoped.update_all(discriminator.field => model.descendants.dup << model)
        end
      end
    end # class Discriminator
  end # class Property
end # module Ardm
