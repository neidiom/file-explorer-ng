# frozen_string_literal: true

require 'test_helper'

class FileSystemOperationsTest < ActiveSupport::TestCase
  setup do
    @test_dir = Rails.root.join('tmp/fs_test')
    FileUtils.mkdir_p(@test_dir)
  end

  teardown do
    FileUtils.rm_rf(@test_dir) if Dir.exist?(@test_dir)
  end

  test "uploads file to directory" do
    target_dir = @test_dir + 'uploads'
    FileUtils.mkdir_p(target_dir)

    uploaded_file =
      Rack::Test::UploadedFile.new('Gemfile', 'text/plain')

    result = FileSystemOperations.upload(
      directory: target_dir,
      file: uploaded_file
    )

    assert result.exist?
    assert_equal uploaded_file.original_filename, result.basename.to_s
  end

  test "rejects files exceeding max size" do
    target_dir = @test_dir + 'uploads'
    FileUtils.mkdir_p(target_dir)

    # Create a mock file that's too large
    large_file = Rack::Test::UploadedFile.new('Gemfile', 'text/plain')
    large_file.stubs(:size).returns(500.megabytes)

    assert_raise(ArgumentError, /File too large/) do
      FileSystemOperations.upload(directory: target_dir, file: large_file)
    end
  end

  test "deletes files" do
    test_file = @test_dir + 'test.txt'
    FileUtils.touch(test_file)
    assert test_file.exist?

    FileSystemOperations.delete(test_file)

    refute test_file.exist?
  end

  test "deletes directories" do
    test_dir = @test_dir + 'test_dir'
    FileUtils.mkdir_p(test_dir)
    FileUtils.touch(test_dir + 'file.txt')
    assert test_dir.exist?

    FileSystemOperations.delete(test_dir)

    refute test_dir.exist?
  end

  test "renames files" do
    old_file = @test_dir + 'old.txt'
    new_file = @test_dir + 'new.txt'
    FileUtils.touch(old_file)
    assert old_file.exist?
    refute new_file.exist?

    FileSystemOperations.rename(from: old_file, to: new_file)

    refute old_file.exist?
    assert new_file.exist?
  end

  test "creates parent directories when moving" do
    old_file = @test_dir + 'old.txt'
    new_file = @test_dir + 'subdir' + 'new.txt'
    FileUtils.touch(old_file)

    assert old_file.exist?
    refute Pathname.new(new_file).parent.exist?

    FileSystemOperations.rename(from: old_file, to: new_file)

    refute old_file.exist?
    assert Pathname.new(new_file).parent.exist?
    assert Pathname.new(new_file).exist?
  end
end
