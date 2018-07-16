# This file must be included in tests of engine components (helpers, concerns).
# In other words, in tests inside the smart_table/app dir.
#
# Tests of the smart_table/lib dir should not require a rails engine and therefore
# should include spec_helper.rb only

require_relative 'spec_helper'

# Loads dummy_app, so we can test the Rails Engine components
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../dummy_app/config/environment", __FILE__)

require 'rspec/rails'
