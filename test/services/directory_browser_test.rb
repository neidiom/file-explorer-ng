# frozen_string_literal: true

require 'test_helper'

class DirectoryBrowserTest < ActiveSupport::TestCase
  setup do
    @test_dir = Rails.root.join('tmp/test_directory')
    FileUtils.mkdir_p(@test_dir)
    FileUtils.touch(@test_dir + 'test_file.txt')
    FileUtils.mkdir(@test_dir + 'subdir')
  end

  teardown do
    FileUtils.rm_rf(@test_dir) if Dir.exist?(@test_dir)
  end

  test "lists directory contents" do
    entries = DirectoryBrowser.list(path: @test_dir.to_s, base_url: '')

    assert_equal ['.', '..', 'test_file.txt', 'subdir'].sort,
                 entries.map(&:name).sort
  end

  test "categories entries correctly" do
    entries = DirectoryBrowser.list(path: @test_dir.to_s, base_url: '')

    file_entry = entries.find { |e| e.name == 'test_file.txt' }
    refute_nil file_entry
    assert_equal :file, file_entry.type
    assert file_entry.file?

    dir_entry = entries.find { |e| e.name == 'subdir' }
    refute_nil dir_entry
    assert_equal :directory, dir_entry.type
    assert dir_entry.directory?
  end

  test "sorts directories before files" do
    entries = DirectoryBrowser.list(path: @test_dir.to_s, base_url: '')

    # Filter out . and .. for test
    entries = entries.select(&:valid?)

    # Directory should come before file
    dir_index = entries.index { |e| e.name == 'subdir' }
    file_index = entries.index { |e| e.name == 'test_file.txt' }

    assert dir_index < file_index
  end

  test "filters out dot entries" do
    entries = DirectoryBrowser.list(path: @test_dir.to_s, base_url: '')

    dot_entries = entries.select { |e| %w[.. .].include?(e.name) }
    assert_equal 2, dot_entries.size
  end

  test "builds correct relative URLs" do
    entries = DirectoryBrowser.list(path: @test_dir.to_s, base_url: 'test/')

    dir_entry = entries.find { |e| e.name == 'subdir' }
    assert_equal 'test/subdir/', dir_entry.relative_url

    file_entry = entries.find { |e| e.name == 'test_file.txt' }
    assert_equal 'test/test_file.txt', file_entry.relative_url
  end
end
