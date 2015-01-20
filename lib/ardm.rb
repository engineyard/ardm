require 'ardm/deprecation'

module Ardm
  NotImplemented = Class.new(RuntimeError)

  class << self

    def load(orm=nil)
      self.orm = orm if orm
      require self.lib
    end

    # Check which ORM is loaded in Ardm.
    #
    # @api public
    def orm
      return @orm if @orm
      self.orm = ENV['ORM']
      @orm
    end

    # Set which orm to load.
    #
    # @api public
    def orm=(orm)
      if defined?(Ardm::Ar) || defined?(Ardm::Dm)
        raise "Cannot change Ardm.orm when #{orm} libs are already loaded."
      end

      @orm = case orm.to_s
             when /(ar|active_?record)/ then :ar
             when /(dm|data_?mapper)/   then :dm
             when "" then raise "Specify Ardm.orm by assigning :ar or :dm or by setting ENV['ORM']"
             else raise "Unknown Ardm.orm. Expected: (ar|dm). Got: #{orm.inspect}"
             end
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
