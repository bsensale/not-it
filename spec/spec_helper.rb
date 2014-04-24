require "rubygems"
require "bundler"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "simplecov"
require "minitest/autorun"
require "vcr"
require "mocha/setup"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "not-it"

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock # or :fakeweb
  c.debug_logger = File.open("vcr.log", "w")
end

module Helpers
  def get_fixture_dir
    File.expand_path(File.join(File.dirname(__FILE__), "fixtures"))
  end
  def get_fixture_file(name)
    File.open(File.join(get_fixture_dir, name))
  end
end
SimpleCov.start
MiniTest.autorun
