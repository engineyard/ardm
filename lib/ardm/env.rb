# Load Ardm based on the $ORM environment variable.
#
require 'ardm'
Ardm.orm = ENV['ORM']
require Ardm.lib
