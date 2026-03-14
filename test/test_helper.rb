# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup_test_directory(path)
    FileUtils.mkdir_p(path)
  end

  def cleanup_test_directory(path)
    FileUtils.rm_rf(path) if Dir.exist?(path)
  end

  def assert_file_exists(path)
    assert File.exist?(path), "Expected file to exist: #{path}"
  end

  def refute_file_exists(path)
    refute File.exist?(path), "Expected file to not exist: #{path}"
  end
end
