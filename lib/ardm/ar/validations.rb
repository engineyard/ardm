require 'active_support/concern'
require 'active_model/validations'

module Ardm
  module Ar
    # Extend ActiveRecord to support DataMapper validations
    module Validations
      extend ActiveSupport::Concern

      include ActiveModel::Validations

      # Extract and convert options from DM style to AR style
      def self.extract_options(fields, *keep)
        keep += [:on, :message, :if, :unless]

        if Hash === fields.last
          ar = fields.pop.dup
          w = Array(ar.delete(:when)).first
          if w && [:create, :update].include?(w)
            ar[:on]    = w
          end
          ar[:maximum] = ar.delete(:max) if ar[:max]
          ar[:minimum] = ar.delete(:min) if ar[:min]
          ar[:in]      = ar.delete(:set) if ar[:set]

          removed = ar.slice!(*keep)
          unless removed.empty?
            $stderr.puts "WARNING validation options not handled: #{removed.inspect} in:"
            $stderr.puts caller[0..1]
          end
        else
          ar = {}
        end

        [fields, ar]
      end

      module ClassMethods

        def validates_belongs_to(*fields)
          fields, options = Ardm::Ar::Validations.extract_options(fields)
          validates *fields, presence: options
        end

        def validates_presence_of(*fields)
          fields, options = Ardm::Ar::Validations.extract_options(fields)

          boolean_fields, non_boolean_fields = fields.partition { |f| self.properties[f.to_sym].is_a?(Ardm::Property::Boolean) }

          if non_boolean_fields.any?
            validates(*non_boolean_fields, presence: options)
          end

          if boolean_fields.any?
            if options.any?
              $stderr.puts "validates_presence_of options ignored: #{options.inspect}"
            end
            validates(*boolean_fields, inclusion: {in: [true, false]})
          end
        end

        def validates_length_of(*fields)
          fields, options = Ardm::Ar::Validations.extract_options(fields, :in, :within, :maximum, :minimum, :is)
          validates *fields, length: options
        end

        def validates_uniqueness_of(*fields)
          fields, options = Ardm::Ar::Validations.extract_options(fields, :scope)
          fields = fields.map do |field|
            if property = properties[field]
              property.field
            elsif assoc = reflect_on_association(field)
              assoc.foreign_key
            else
              field
            end
          end

          if options[:scope]
            options[:scope] = Array(options[:scope]).map do |scope|
              assoc = reflect_on_association(scope)
              assoc ? assoc.foreign_key : scope
            end
          end

          validates *fields, uniqueness: options
        end

        def validates_within(*fields)
          fields, options = Ardm::Ar::Validations.extract_options(fields, :in)
          validates *fields, inclusion: options
        end

        # Possible formats:
        #
        # validates_with_method :attr, :method_name
        # validates_with_method :attr, method: :method_name
        # validates_with_method :method_name, options: "here"
        def validates_with_method(*fields)
          fields, options = Ardm::Ar::Validations.extract_options(fields, :method)

          # validates_with_method :attr, :method_name
          att, meth = *fields

          # validates_with_method :attr, method: :method_name
          meth = options[:method] if options[:method]

          # validates_with_method :method_name
          att, meth = :base, att if !meth

          validates_with_block(att) do
            self.send(meth)
          end
        end

        def validates_with_block(*args, &block)
          options   = args.extract_options!
          attribute = args.shift

          validate(options) do |_|
            is_valid, message = instance_eval(&block)

            unless is_valid
              attribute ||= :base

              if attribute.to_sym == :base
                raise "message is blank #{args.inspect} #{self.inspect} #{block.inspect}" if message.blank?
              end

              errors.add(attribute, message)
            end
          end
        end
      end
    end
  end
end
