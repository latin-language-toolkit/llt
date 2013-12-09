lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'llt/api'
use ActiveRecord::ConnectionAdapters::ConnectionManagement
run Api
