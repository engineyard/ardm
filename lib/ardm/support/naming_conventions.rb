module Ardm

  # Use these modules to establish naming conventions.
  # The default is UnderscoredAndPluralized.
  # You assign a naming convention like so:
  #
  #   connection.adapter.resource_naming_convention = NamingConventions::Resource::Underscored
  #
  # You can also easily assign a custom convention with a Proc:
  #
  #   connection.adapter.resource_naming_convention = lambda do |value|
  #     'tbl' + value.camelize(true)
  #   end
  #
  # Or by simply defining your own module in NamingConventions that responds to
  # ::call.
  #
  # NOTE: It's important to set the convention before accessing your models
  # since the resource_names are cached after first accessed.
  # Ardm.setup(name, uri) returns the Adapter for convenience, so you can
  # use code like this:
  #
  #   adapter = Ardm.setup(:default, 'mock://localhost/mock')
  #   adapter.resource_naming_convention = NamingConventions::Resource::Underscored
  module NamingConventions

    module Resource

      module UnderscoredAndPluralized
        def self.call(name)
          Ardm::Inflector.pluralize(Ardm::Inflector.underscore(name)).gsub('/', '_')
        end
      end # module UnderscoredAndPluralized

      module UnderscoredAndPluralizedWithoutModule
        def self.call(name)
          Ardm::Inflector.pluralize(Ardm::Inflector.underscore(Ardm::Inflector.demodulize(name)))
        end
      end # module UnderscoredAndPluralizedWithoutModule

      module UnderscoredAndPluralizedWithoutLeadingModule
        def self.call(name)
          UnderscoredAndPluralized.call(name.to_s.gsub(/^[^:]*::/,''))
        end
      end

      module Underscored
        def self.call(name)
          Ardm::Inflector.underscore(name)
        end
      end # module Underscored

      module Yaml
        def self.call(name)
          "#{Ardm::Inflector.pluralize(Ardm::Inflector.underscore(name))}.yaml"
        end
      end # module Yaml

    end # module Resource

    module Field

      module UnderscoredAndPluralized
        def self.call(property)
          Ardm::Inflector.pluralize(Ardm::Inflector.underscore(property.name.to_s)).gsub('/', '_')
        end
      end # module UnderscoredAndPluralized

      module UnderscoredAndPluralizedWithoutModule
        def self.call(property)
          Ardm::Inflector.pluralize(Ardm::Inflector.underscore(Ardm::Inflector.demodulize(property.name.to_s)))
        end
      end # module UnderscoredAndPluralizedWithoutModule

      module Underscored
        def self.call(property)
          Ardm::Inflector.underscore(property.name.to_s)
        end
      end # module Underscored

      module Yaml
        def self.call(property)
          "#{Ardm::Inflector.pluralize(Ardm::Inflector.underscore(property.name.to_s))}.yaml"
        end
      end # module Yaml

    end # module Field

  end # module NamingConventions
end # module Ardm
