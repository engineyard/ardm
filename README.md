# Ardm

ActiveRecord plugin to provide a smooth migration from DataMapper to ActiveRecord.

## Why

Ardm is intended for applications running Rails with DataMapper 1.2 who need
to migrate to ActiveRecord. Lets examine some of the reasons why you might
move to ActiveRecord.

* DataMapper is no longer under development. Ruby Object Mapper (ROM) is the
  imlicit replacement for DataMapper, but it's not a supported migration. ROM
  is a completely new codebase and very few of the idioms transfer.
* DataMapper produces inefficient queries. Includes, joins, and subqueries are
  either not supported or incorrect. Enabling subqueries in DM speeds up queries
  but causes other subtle query problems than can produce bad SQL that may
  select incorrect records.
* DataMapper cannot currently run on Rails4. Someone may take the initiative to
  upgrade DataMapper to work on Rails4, but I think you're much better off
  moving to ActiveRecord.
* Arel is awesome. ActiveRecord and Arel together is quite nice. With the added
  support properties and the advances in Rails4, I think this upgrade is a must.
* ActiveRecord is used in more applications, better tested, and more performant.

## Installation

Incremental migration from DataMapper to ActiveRecord.

ActiveRecord requires your models to inherit from ActiveRecord::Base, but makes
it difficult to approach the migration incrementally. All or nothing is a scary
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
developing your application in DataMapper while you work on teasing out all
the "datamapper-isms" from your code. This library attempts to take care of
most DataMapper features, but there are probably tons of small variations
that are not accounted for.

## Usage

  require 'ardm'



## Copyright

This is an adaptation of the original DataMapper source code to allow
users of the now defunct DataMapper to migrate to ActiveRecord.
Much of this code was originally written by Sam Smoot and Dan Kubb as
[dm-types](https://github.com/datamapper/dm-types) and
[dm-core](https://github.com/datamapper/dm-core). See LICENSE for details.
