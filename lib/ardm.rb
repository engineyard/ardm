require 'ardm/deprecation'

module Ardm
  NotImplemented = Class.new(RuntimeError)

  class << self

    # Setup the ORM using orm arg or $ORM, then require the correct shim libs.
    #
    # If an ORM is not specified as an argument, ENV['ORM'] will be used.
    # If $ORM is not set, then Ardm will raise.
    #
    # Execute the block if one is given. This is a good time to require
    # active_record or dm-core using Ardm.ar or Ardm.dm blocks.
    #
    #     Ardm.setup ENV['ORM'] do
    #       Ardm.ar do
    #         Bundler.require(:active_record)
    #         require "active_record/railtie"
    #       end
    #       Ardm.dm { Bundler.require(:data_mapper) }
    #     end
    #
    # The Ardm shim libs will be required after the block returns.
    #
    # @api public
    def setup(orm=nil)
      self.orm = orm if orm
      yield self if block_given?
      require lib
    end

    # Check which ORM is loaded in Ardm.
    #
    # @api public
    def orm
      if @orm
        return @orm
      else
        self.orm = ENV['ORM']
      end
      @orm
    end

    # Set which orm to load.
    #
    # @api public
    def orm=(orm)
      neworm =
        case orm.to_s
        when /(ar|active_?record)/ then :ar
        when /(dm|data_?mapper)/   then :dm
        when "" then raise "Specify Ardm.orm by assigning :ar or :dm or by setting ENV['ORM']"
        else raise "Unknown Ardm.orm. Expected: (ar|dm). Got: #{orm.inspect}"
        end

      if @orm == neworm
        return @orm
      end

      if defined?(Ardm::Ar) || defined?(Ardm::Dm)
        raise "Cannot change Ardm.orm when #{self.orm} libs are already loaded."
      end

      @orm = neworm
    end

    def lib
      "ardm/#{orm}"
    end

    # Return true if Ardm has loaded ActiveRecord ORM.
    #
    # @api public
    def ar?
      orm == :ar
    end
    alias activerecord? ar?
    alias active_record? ar?

    # Return true if Ardm has loaded DataMapper ORM.
    #
    # @api public
    def dm?
      orm == :dm
    end
    alias datamapper? dm?
    alias data_mapper? dm?

    # Yield if Ardm has loaded ActiveRecord ORM.
    #
    # @api public
    def ar
      yield if block_given? && ar?
    end
    alias activerecord ar
    alias active_record ar

    # Yield if Ardm has loaded DataMapper ORM.
    #
    # @api public
    def dm
      yield if block_given? && dm?
    end

    alias datamapper dm
    alias data_mapper dm

    def rails3?
      ar? && ::ActiveRecord::VERSION::STRING >= "3.0" && ::ActiveRecord::VERSION::STRING <= "4.0"
    end

    def rails4?
      ar? && !rails3?
    end
  end
end
