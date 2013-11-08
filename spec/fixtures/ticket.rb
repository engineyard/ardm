module Ardm
  module Fixtures
    class Ticket < ::Ardm::Record
      self.table_name = "tickets"

      property :id,     Serial
      property :title,  String, :length => 255
      property :body,   Text
      property :status, Enum[:unconfirmed, :confirmed, :assigned, :resolved, :not_applicable]
    end # Ticket
  end
end
