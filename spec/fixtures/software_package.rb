module Ardm
  module Fixtures
    class SoftwarePackage < ::Ardm::Record
      self.table_name = "software_packages"

      property :id, Serial
      property :node_number, Integer, :index => true

      property :source_path,      FilePath
      property :destination_path, FilePath

      property :product,     String
      property :version,     String
      property :released_at, DateTime

      property :security_update,  Boolean

      property :installed_at,     DateTime
      property :installed_by,     String
    end # SoftwarePackage
  end # Fixtures
end # Ardm
