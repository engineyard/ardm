module Ardm
  module Fixtures
    class Person < Ardm::Record
      self.table_name = "people"

      property :id,         Serial
      property :name,       String
      property :positions,  Json
      property :inventions, Yaml
      property :birthday,   EpochTime

      property :interests, CommaSeparatedList

      property :password, BCryptHash
    end
  end
end
