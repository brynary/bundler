require 'logger'
require 'set'
# Required elements of rubygems
require "rubygems/remote_fetcher"
require "rubygems/installer"

require "bundler/gem_bundle"
require "bundler/installer"
require "bundler/finder"
require "bundler/gem_specification"
require "bundler/resolver"
require "bundler/manifest"
require "bundler/dependency"
require "bundler/runtime"

module Bundler
  VERSION = "0.5.0"
end