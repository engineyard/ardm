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

    require 'ardm'

Run your project using the ORM environment variable.

    ORM=activerecord bundle exec rake spec
    ORM=datamapper bundle exec rake spec

## Incremental migration from DataMapper to ActiveRecord

ActiveRecord requires your models to inherit from ActiveRecord::Base, which makes
it difficult to approach this migration incrementally. All or nothing is a scary
way to switch ORMs. To solve this, Ardm supplies Ardm::Record.

Ardm::Record will be the new base class. You'll need to search and replace
all models that include DataMapper::Resource, remove it, and add Ardm::Record
as the base class. If your model is STI, add it to the base model and remove
DataMapper::Resource from all models.

Example:

    class MyModel
      include DataMapper::Resource
      # ...
    end

    # The model above changes to:

    class MyModel < Ardm::Record
      # ...
    end

With this new base clase you can switch between ActiveRecord and DataMapper
by flipping a swith in your application. This approach allows you to continue
developing your application in DataMapper while you work on removing all
the "datamapper-isms" from your code. This library attempts to take care of
most DataMapper features, but there are probably tons of small variations
that are not accounted for.

## General Strategy

This is a complex thing to approach. I'm hoping this project can make this move
into a repeatable strategy rather than everyone needing to create their own
unique solution.

1. Get the application running with Ardm installed. Don't even think about
   ActiveRecord until you have Ardm working in DataMapper mode and you can
   deploy your application normally with ardm installed.
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

## Conversions

Things that access DataMapper directly can be replaced with Ardm invocations:

    DataMapper.finalize    =>  Ardm::Record.finalize (no-op in AR mode)
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

    if Ardm.activerecord?
      Thing.where(Thing.arel_table[:field].matches('something'))
    else
      # This is just an example. This should actually work fine in Ardm.
      Thing.all(:field.like => 'something')
    end

## Copyright

This is an adaptation of the original DataMapper source code to allow
users of the now defunct DataMapper to migrate to ActiveRecord.
Much of this code was originally written by Sam Smoot and Dan Kubb as
[dm-types](https://github.com/datamapper/dm-types) and
[dm-core](https://github.com/datamapper/dm-core). See LICENSE for details.
