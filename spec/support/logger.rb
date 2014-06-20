RSpec.configure do |config|
  config.before(:each) do
    require 'active_support/logger'
    logger = if ENV["VERBOSE"]
               ActiveSupport::Logger.new(STDOUT)
             else
               Logger.new(nil)
             end
    if defined?(::ActiveRecord::Base)
      ::ActiveRecord::Base.logger = logger
    elsif defined?(::DataMapper)
      ::DataMapper.logger = logger
    end
  end
end
