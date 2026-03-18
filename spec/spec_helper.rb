# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'
SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::JSONFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ])
    add_filter '/spec/'
    track_files "lib/**/*.rb"
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
