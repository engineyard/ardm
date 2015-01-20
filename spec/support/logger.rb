if defined?(::DataMapper)
  module ::DataMapper::LogListener
    def log(message)
      ::DataMapper.logger.info("#{message.query}")
      super
    rescue Exception => e
      ::DataMapper.logger.error "[datamapper] #{e.class.name}: #{e.message}: #{message.inspect}}"
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    require 'logger'
    logger = Logger.new(nil)

    if Ardm.rails4?
      require 'active_support/logger'
      logger = if ENV["VERBOSE"]
                 ActiveSupport::Logger.new(STDOUT)
               end
    end

    if defined?(::ActiveRecord::Base)
      ::ActiveRecord::Base.logger = logger
    elsif defined?(::DataMapper)
      require 'active_support/inflector'
      driver = DataObjects.const_get(ActiveSupport::Inflector.camelize('sqlite3'), false)

      DataObjects::Connection.send(:include, ::DataMapper::LogListener)
      # FIXME Setting DataMapper::Logger.new($stdout, :off) alone won't work because the #log
      # method is currently only available in DO and needs an explicit DO Logger instantiated.
      # We turn the logger :off because ActiveSupport::Notifications handles displaying log messages
      driver.logger = DataObjects::Logger.new($stdout, :off)
      ::DataMapper.logger = logger
    end
  end
end
