# Ardm

ActiveRecord plugin to provide a smooth migration from DataMapper to ActiveRecord.

This code is currently in development and not feature complete.
Your code is probably different than mine, so please contribute to bridge
the gap from DataMapper to ActiveRecord and Rails 4.

## Why

Ardm is intended for applications running Rails with DataMapper 1.2 who need
to migrate to ActiveRecord so they can move forward onto Rails 4.
Lets examine some of the reasons why you might move to ActiveRecord.

* DataMapper is no longer under development. Ruby Object Mapper (ROM) is the
  implicit replacement for DataMapper, but it's not a supported migration.
  ROM is a completely new codebase and very few of the idioms transfer.
* DataMapper produces inefficient queries. Includes, joins, and subqueries are
  either not supported or incorrect. Enabling subqueries in DM speeds up queries
  but causes other subtle query problems than can produce bad SQL that may
  select incorrect records.
* DataMapper cannot currently run on Rails 4. Someone may take the initiative to
  upgrade DataMapper to work on Rails4, but I think you're much better off
  moving to ActiveRecord.
* Arel is awesome. ActiveRecord and Arel together is quite nice. With the added
  support properties and the advances in Rails 4, I think this upgrade is a must.
* ActiveRecord is used in more applications, is better tested, and is more
  performant than DataMapper.

## Installation

Near the top of your config/application.rb, add the following:

    require 'ardm'
    Ardm.orm = ENV['ORM'] || :dm # default

    Ardm.ar do # only executed if ORM is ActiveRecord
      Bundler.require(:active_record) # libs related to active record
      require "active_record/railtie"
    end
    Ardm.dm do # only executed if ORM is DataMapper
      Bundler.require(:data_mapper) # libs related to data mapper
    end
    Ardm.setup # this requires the Ardm shim code

Next you need to change add a base class to EVERY model that previously
included DataMapper::Resource.

This is very tedious but there's no way around it. All ActiveRecord
models must inherit from ActiveRecord::Base, so Ardm creates an interchangeable
base class that can be either ActiveRecord or DataMapper.

If your model is STI, add it to the base model.

I'm sorry, it's the only way.

    app/models/my_model.rb

    class MyModel < Ardm::Record # <--- add this
      include DataMapper::Resource # you can remove this (it should also be shimmed)
    end

Run your project using the ORM environment variable.

    # Try to get this one working now with the changes above.
    ORM=dm bundle exec rake spec

    # This will fail horribly
    ORM=ar bundle exec rake spec

With this new base clase and the ORM environment variable, you can switch
between ActiveRecord and DataMapper by flipping the ORM variable.

This approach allows you to continue developing your application in
DataMapper while you work on removing all the "datamapper-isms" from your
code. This library attempts to take care of most DataMapper features, but
there are probably tons of small variations that are not accounted for.

## General Strategy

1. Get the application running in DataMapper with Ardm installed. Don't even
   think about ActiveRecord until you have Ardm working in DataMapper mode and
   you can deploy your application normally with ardm installed.
2. Start to remove references to `DataMapper` by using the conversions
   mentioned below. The idea is to remove the `DataMapper` constant completely
   so you can run without `dm-core` when in ActiveRecord mode.
3. Once your application runs smoothly in DataMapper mode with all the
   constants using Ardm, try to get the application to start the test run
   in ActiveRecord mode. This will probably require a bunch of hunting through
   the application for datamapper-isms that are not accounted for in Ardm.
   **Please help by contributing these fixes back to Ardm!**
4. Make all your tests pass in ActiveRecord and DataMapper mode. This is an
   ideal. You could decide that you're close enough and start sacrificing
   DataMapper specific code for ActiveRecord code. You can branch around
   picky code with the `Ardme.activerecord?` and `Ardm.datamapper?` helpers.

This is a complex thing to approach. I hope Ardm will make this change
into a repeatable strategy rather than everyone needing to create their own
unique solution.

## Conversions

Things that access DataMapper directly can be replaced with Ardm invocations:

    DataMapper.finalize    =>  Ardm::Record.finalize # this is still important for Ardm
    DataMapper.repository  =>  Ardm::Record.repository
    DataMapper.logger      =>  Ardm::Record.logger

    DataMapper::ObjectNotFoundError => Ardm::Record::NotFound
    ActiveRecord::RecordNotFound    => Ardm::Record::NotFound

    DataMapper::Property           =>  Ardm::Property
    DataMapper::Property::String   =>  Ardm::Property::String

This pattern follows for most DataMapper module methods. When running in
DataMapper mode, these simply forward. In ActiveRecord mode, they provide
adapters for accessing the same data through ActiveRecord.

If you run into code that is particularly difficult to convert, you can
duplicate the code and write a different version for each ORM:

    Ardm.ar { Thing.where(Thing.arel_table[:field].matches('something')) }
    # This is just an example. This should actually work fine in Ardm.
    Ardm.dm { Thing.all(:field.like => 'something') }

## Copyright

This is an adaptation of the original DataMapper source code to allow
users of the now defunct DataMapper to migrate to ActiveRecord.
Much of this code was originally written by Sam Smoot and Dan Kubb as
[dm-types](https://github.com/datamapper/dm-types) and
[dm-core](https://github.com/datamapper/dm-core). See LICENSE for details.
