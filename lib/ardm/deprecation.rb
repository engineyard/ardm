module Ardm
  module Deprecation
    def self.deprecations
      @deprecations ||= begin
                          at_exit { print_deprecations }
                          {}
                        end
    end

    def self.print_deprecations
      $stderr.puts 'Deprecations by count:'
      $stderr.puts deprecations.sort_by { |_,v| -v }.map { |message, count| "[%5d] %s" % [count, message] }
    end

    def self.warn(message)
      message = "DEPRECATED: #{message} at #{caller[2].sub(Rails.root.to_s,'')}"
      deprecations[message] ||= 0
      deprecations[message] += 1
      if deprecations[message] == 1
        $stderr.puts message
      end
    end
  end
end
