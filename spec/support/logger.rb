RSpec.configure do |config|
  config.before(:each) do
    if ENV["VERBOSE"] && defined?(::ActiveRecord::Base)
      ::ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
    else
      ::ActiveRecord::Base.logger = Logger.new(nil)
    end
  end
end
