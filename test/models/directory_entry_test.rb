# frozen_string_literal: true

require 'test_helper'

class DirectoryEntryTest < ActiveSupport::TestCase
  test "identifies file entries" do
    entry = DirectoryEntry.new(
      name: 'test.txt',
      path: '/path/to/test.txt',
      type: :file,
      size: 1024,
      modified_at: Time.now,
      relative_url: 'test.txt'
    )

    assert entry.file?
    refute entry.directory?
  end

  test "identifies directory entries" do
    entry = DirectoryEntry.new(
      name: 'test',
      path: '/path/to/test',
      type: :directory,
      size: nil,
      modified_at: Time.now,
      relative_url: 'test/'
    )

    assert entry.directory?
    refute entry.file?
  end

  test "ranks directories before files" do
    file_entry = DirectoryEntry.new(
      name: 'test.txt',
      path: '/test.txt',
      type: :file,
      size: 1024,
      modified_at: Time.now,
      relative_url: 'test.txt'
    )

    dir_entry = DirectoryEntry.new(
      name: 'test',
      path: '/test',
      type: :directory,
      size: nil,
      modified_at: Time.now,
      relative_url: 'test/'
    )

    assert_equal 0, dir_entry.rank
    assert_equal 1, file_entry.rank
    assert dir_entry.rank < file_entry.rank
  end

  test "formats human readable file size" do
    entry = DirectoryEntry.new(
      name: 'test.txt',
      path: '/test.txt',
      type: :file,
      size: 1_048_576, # 1 MB
      modified_at: Time.now,
      relative_url: 'test.txt'
    )

    assert_match(/1\.0 MB/, entry.human_size)
  end

  test "formats file size as dash for directories" do
    entry = DirectoryEntry.new(
      name: 'test',
      path: '/test',
      type: :directory,
      size: nil,
      modified_at: Time.now,
      relative_url: 'test/'
    )

    assert_equal '-', entry.human_size
  end

  test "formats modified date" do
    time = Time.new(2026, 3, 14, 12, 30, 0)
    entry = DirectoryEntry.new(
      name: 'test',
      path: '/test',
      type: :directory,
      size: nil,
      modified_at: time,
      relative_url: 'test/'
    )

    assert_match(/\d{2} \w{3} \d{4} \d{2}:\d{2}/, entry.formatted_date)
  end

  test "returns correct icon class for files" do
    entry = DirectoryEntry.new(
      name: 'test.txt',
      path: '/test.txt',
      type: :file,
      size: 1024,
      modified_at: Time.now,
      relative_url: 'test.txt'
    )

    assert_equal 'fa-file', entry.icon_class
  end

  test "returns correct icon class for directories" do
    entry = DirectoryEntry.new(
      name: 'test',
      path: '/test',
      type: :directory,
      size: nil,
     modified_at: Time.now,
      relative_url: 'test/'
    )

    assert_equal 'fa-folder', entry.icon_class
  end

  test "display_name includes trailing slash for directories" do
    entry = DirectoryEntry.new(
      name: 'test',
      path: '/test',
      type: :directory,
      size: nil,
      modified_at: Time.now,
      relative_url: 'test/'
    )

    assert_equal 'test/', entry.display_name
  end

  test "display_name does not include trailing slash for files" do
    entry = DirectoryEntry.new(
      name: 'test.txt',
      path: '/test.txt',
      type: :file,
      size: 1024,
      modified_at: Time.now,
      relative_url: 'test.txt'
    )

    assert_equal 'test.txt', entry.display_name
  end
end
