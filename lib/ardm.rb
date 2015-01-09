require 'ardm/deprecation'

module Ardm
  NotImplemented = Class.new(RuntimeError)

  # Check which ORM is loaded in Ardm.
  #
  # @api public
  def self.orm
    @orm ||= :active_record
  end

  # Set which orm to load.
  #
  # @api public
  def self.orm=(orm)
    if defined?(Ardm::ActiveRecord) || defined?(Ardm::DataMapper)
      raise "Cannot change Ardm.orm when #{orm} libs are already loaded."
    end

    @orm = case orm.to_s
           when /active_?record/, '' then :active_record
           when /data_?mapper/       then :data_mapper
           else raise "Unknown ENV['ORM']: #{ENV['ORM']}"
           end
  end

  # Return true if Ardm has loaded ActiveRecord ORM.
  #
  # @api public
  def self.active_record?
    orm == :active_record
  end

  # Return true if Ardm has loaded DataMapper ORM.
  #
  # @api public
  def self.data_mapper?
    orm == :data_mapper
  end

  # Yield if Ardm has loaded ActiveRecord ORM.
  #
  # @api public
  def self.active_record
    yield if block_given? && active_record?
  end

  def self.rails3?
    self.active_record? && ::ActiveRecord::VERSION::STRING >= "3.0" && ::ActiveRecord::VERSION::STRING <= "4.0"
  end

  def self.rails4?
    self.active_record? && !self.rails3?
  end

  # Yield if Ardm has loaded DataMapper ORM.
  #
  # @api public
  def self.data_mapper
    yield if block_given? && data_mapper?
  end

  def self.lib
    "ardm/#{orm}"
  end
end
