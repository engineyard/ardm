module Ardm
  module PropertyFixtures
    class NetworkNode < ActiveRecord::Base
      self.table_name = "network_nodes"

      property :id,               Serial
      property :ip_address,       IPAddress
      property :cidr_subnet_bits, Integer
      property :node_uuid,        UUID

      alias_method :uuid,  :node_uuid
      alias_method :uuid=, :node_uuid=

      def runs_ipv6?
        self.ip_address.ipv6?
      end

      def runs_ipv4?
        self.ip_address.ipv4?
      end
    end # NetworkNode
  end # PropertyFixtures
end # Ardm
