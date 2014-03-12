lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# to fix the git gem load errors with warbler...
require 'bundler'
Bundler.setup(:default)

require 'llt/api'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Api
