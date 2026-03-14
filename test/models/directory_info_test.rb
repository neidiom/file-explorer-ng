# frozen_string_literal: true

require 'test_helper'

class DirectoryInfoTest < ActiveSupport::TestCase
  setup do
    @base_dir = Rails.root.join('tmp', 'test_dir')
    FileUtils.mkdir_p(@base_dir)
    FileUtils.mkdir(@base_dir + 'subdirectory')
    FileUtils.touch(@base_dir + 'file.txt')
  end

  teardown do
    FileUtils.rm_rf(@base_dir) if Dir.exist?(@base_dir)
  end

  test "displays correct path name" do
    info = DirectoryInfo.new(@base_dir.to_s, request_path: 'subdirectory')
    assert_equal 'subdirectory', info.display_path
  end

  test "displays root label for empty path" do
    info = DirectoryInfo.new(@base_dir.to_s, request_path: '')
    assert_equal 'root', info.display_path
  end

  test "generates breadcrumbs for nested path" do
    info = DirectoryInfo.new(@base_dir.to_s, request_path: 'folder/subfolder')

    breadcrumbs = info.breadcrumbs
    assert_equal 2, breadcrumbs.size
    assert_equal 'folder', breadcrumbs.first.name
    assert_equal 'subfolder', breadcrumbs.last.name
  end

  test "breadcrumbs have correct URLs" do
    info = DirectoryInfo.new(@base_dir.to_s, request_path: 'folder/subfolder')

    breadcrumbs = info.breadcrumbs
    assert_equal '/folder', breadcrumbs.first.url
    assert_equal '/folder/subfolder', breadcrumbs.last.url
  end

  test "root? returns true for empty request path" do
    info = DirectoryInfo.new(@base_dir.to_s, request_path: '')
    assert info.root?
  end

  test "root? returns false for non-empty path" do
    info = DirectoryInfo.new(@base_dir.to_s, request_path: 'something')
    refute info.root?
  end

  test "loads directory entries" do
    info = DirectoryInfo.new(@base_dir.to_s)
    assert_not_empty info.entries
    assert info.entries.any? { |e| e.name == 'subdirectory' }
    assert info.entries.any? { |e| e.name == 'file.txt' }
  end
end
