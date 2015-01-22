#Bundler.require(:default, :test)
require 'rspec'

require 'ardm'
Ardm.orm = ENV['ORM'] || 'active_record'
Ardm.setup

require 'database_cleaner'

Dir["#{Pathname(__FILE__).dirname.expand_path}/{shared,support}/*.rb"].each { |file| require file }

Ardm.ar do
  ActiveRecord::Base.configurations = { "ardm" => {
    "database" => "db/test.sqlite",
    "adapter" => "sqlite3"
  }}
  ActiveRecord::Base.establish_connection 'ardm'

  begin
    $stdout = StringIO.new
    load Pathname.new(__FILE__).dirname.expand_path.join("schema.rb")
  ensure
    $stdout = STDOUT
  end
end

Ardm.dm do
  Bundler.require(:datamapper)
  DataMapper.setup(:default, "sqlite3://#{File.expand_path("../../db/test.sqlite", __FILE__)}")
  DataMapper.auto_migrate!
end

Dir["#{Pathname(__FILE__).dirname.expand_path}/fixtures/*.rb"].each { |file| require file }

Ardm::Record.finalize

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  if ENV["ORM"] == "active_record"
    config.filter_run_excluding(:dm => true)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  def reset_raise_on_save_failure(object)
    name = :raise_on_save_failure
    ivar = "@#{name}"

    if object.respond_to? :singleton_class
      object.singleton_class.class_eval do
        remove_possible_method(name)
      end
    end

    object.instance_eval do
      if instance_variable_defined?(ivar)
        remove_instance_variable(ivar)
      end
    end
  end
end

DEPENDENCIES = {
  'bcrypt' => 'bcrypt-ruby',
}

def try_spec
  begin
    yield
  rescue LoadError => error
    match = error.message.match(/\Ano such file to load -- (.+)\z/)
    raise error unless match && (lib = match[1])

    gem_location = DEPENDENCIES[lib] || raise("Unknown lib #{lib}")

    warn "[WARNING] Skipping specs using #{lib}, please do: gem install #{gem_location}"
  end
end
