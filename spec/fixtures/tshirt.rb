module Ardm
  module Fixtures
      class TShirt < ::Ardm::Record
        self.table_name = "tshirts"

        property :id,          Serial
        property :writing,     String
        property :has_picture, Boolean, :default => false, :required => true
        property :picture,     Enum[:octocat, :fork_you, :git_down]

        property :color, Enum[:white, :black, :red, :orange, :yellow, :green, :cyan, :blue, :purple]
        property :size,  Flag[:xs, :small, :medium, :large, :xl, :xxl], :default => :xs
      end # Shirt
    end # Fixtures
end # Ardm
