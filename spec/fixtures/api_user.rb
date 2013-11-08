module Ardm
  module Fixtures
    class APIUser < Ardm::Record
      self.table_name = "api_users"

      property :id, Serial
      property :name, String
      property :api_key, APIKey
    end
  end
end
