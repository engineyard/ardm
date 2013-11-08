require 'ardm/property'
require 'ardm/property/string'
require 'ardm/property/text'
require 'ardm/property/numeric'

module Ardm
  class Property
    unless defined?(Infinity)
      Infinity = 1.0/0
    end
    Ardm::Property.accept_options :auto_validation, :validates, :set, :format, :message, :messages

    module Validation

      # Infer validations for a given property. This will only occur
      # if the option :auto_validation is either true or left undefined.
      #
      #   Triggers that generate validator creation
      #
      #   :required => true
      #       Setting the option :required to true causes a Rule::Presence
      #       to be created for the property
      #
      #   :length => 20
      #       Setting the option :length causes a Rule::Length to be created
      #       for the property.
      #       If the value is a Integer the Rule will have :maximum => value.
      #       If the value is a Range the Rule will have :within => value.
      #
      #   :format => :predefined / lambda / Proc
      #       Setting the :format option causes a Rule::Format to be created
      #       for the property
      #
      #   :set => ["foo", "bar", "baz"]
      #       Setting the :set option causes a Rule::Within to be created
      #       for the property
      #
      #   Integer type
      #       Using a Integer type causes a Rule::Numericalness to be created
      #       for the property.  The Rule's :integer_only option is set to true
      #
      #   BigDecimal or Float type
      #       Using a Integer type causes a Rule::Numericalness to be created
      #       for the property.  The Rule's :integer_only option will be set
      #       to false, and precision/scale will be set to match the Property
      #
      #
      #   Messages
      #
      #   :messages => {..}
      #       Setting :messages hash replaces standard error messages
      #       with custom ones. For instance:
      #       :messages => {:presence => "Field is required",
      #                     :format => "Field has invalid format"}
      #       Hash keys are: :presence, :format, :length, :is_unique,
      #                      :is_number, :is_primitive
      #
      #   :message => "Some message"
      #       It is just shortcut if only one validation option is set
      #
      # @api private
      def self.rules_for_property(property)
        rule_definitions = []

        # all inferred rules should not be skipped when the value is nil
        #   (aside from Rule::Presence/Rule::Absence)
        opts = { :allow_nil => true }

        if property.options.key?(:validates)
          opts[:context] = property.options[:validates]
        end

        rule_definitions << infer_presence(  property, opts.dup)
        rule_definitions << infer_length(    property, opts.dup)
        rule_definitions << infer_format(    property, opts.dup)
        rule_definitions << infer_uniqueness(property, opts.dup)
        rule_definitions << infer_within(    property, opts.dup)
        rule_definitions << infer_type(      property, opts.dup)

        rule_definitions.compact
      end

      private

      # @api private
      # Skip TrueClass dump because presence is invalid for false, but boolean false is ok for a boolean property.
      def self.infer_presence(property, options)
        return if property.allow_blank? || property.serial? || property.dump_as == ::TrueClass

        validation_options = options_with_message(options, property, :presence)

        {presence: validation_options}
      end

      # @api private
      def self.infer_length(property, options)
        # TODO: return unless property.primitive <= String (?)
        return unless (property.kind_of?(Property::String) ||
                       property.kind_of?(Property::Text))
        length = property.options.fetch(:length, Property::String.length)


        if length.is_a?(Range)
          if length.last == Infinity
            raise ArgumentError, "Infinity is not a valid upper bound for a length range"
          end
          options[:in]  = length
        else
          options[:maximum] = length
        end

        validation_options = options_with_message(options, property, :length)

        {length: validation_options}
      end

      # @api private
      def self.infer_format(property, options)
        return unless property.options.key?(:format)

        options[:with] = property.options[:format]

        validation_options = options_with_message(options, property, :format)

        {format: validation_options}
      end

      # @api private
      def self.infer_uniqueness(property, options)
        return unless property.options.key?(:unique)

        case value = property.options[:unique]
        when Array, Symbol
          # TODO: fix this to behave like :unique_index
          options[:scope] = Array(value)

          validation_options = options_with_message(options, property, :is_unique)
          {uniqueness: validation_options}
        when TrueClass
          validation_options = options_with_message(options, property, :is_unique)
          {uniqueness: validation_options}
        end
      end

      # @api private
      def self.infer_within(property, options)
        return unless property.options.key?(:set)

        options[:in] = property.options[:set]
        options[:message] ||= "must be one of #{options[:in].join(', ')}"

        validation_options = options_with_message(options, property, :within)
        {inclusion: validation_options}
      end

      # @api private
      def self.infer_type(property, options)
        return if property.respond_to?(:custom?) && property.custom?

        if property.kind_of?(Property::Numeric)
          options[:greater_than_or_equal_to] = property.min if property.min
          options[:less_than_or_equal_to] = property.max if property.max
        end

        if Integer == property.load_as
          options[:only_integer] = true

          validation_options = options_with_message(options, property, :is_number)
          {numericality: validation_options}
        elsif (BigDecimal == property.load_as ||
               Float == property.load_as)
          options[:precision] = property.precision
          options[:scale]     = property.scale

          validation_options = options_with_message(options, property, :is_number)
          {numericality: validation_options}
        else
          # We only need this in the case we don't already
          # have a numeric validator, because otherwise
          # it will cause duplicate validation errors
          validation_options = options_with_message(options, property, :is_primitive)
          # FIXME unsupported in Ardm::Property for now
          nil
        end
      end

      # TODO: eliminate this;
      #   mutating one arg based on a non-obvious interaction of the other two...
      #   well, it makes my skin crawl.
      # 
      # @api private
      def self.options_with_message(base_options, property, validator_name)
        options = base_options.clone
        opts    = property.options

        if opts.key?(:messages)
          options[:message] = opts[:messages][validator_name]
        elsif opts.key?(:message)
          options[:message] = opts[:message]
        end

        options
      end

    end # module Validation
  end # module Property
end # module Ardm

