# frozen_string_literal: true

require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  setup do
    @temp_dir = Rails.root.join('tmp', 'test_files')
    FileUtils.mkdir_p(@temp_dir)
    Rails.application.config.x.allowed_directories = [@temp_dir.to_s]
  end

  teardown do
    FileUtils.rm_rf(@temp_dir) if Dir.exist?(@temp_dir)
  end

  def test_success_root
    ENV['BASE_DIRECTORY'] = @temp_dir.to_s

    get '/'

    assert_response :success
    assert_template :index
  end

  def test_success_file_display
    filename = 'Gemfile'
    get "/#{filename}"

    assert_response :success
    assert_template :file
  end

  def test_out_of_directory_access
    ENV['BASE_DIRECTORY'] = @temp_dir.to_s

    assert_raise(ArgumentError) do
      get '/../../etc/passwd'
    end
  end

  def test_move
    old_filename = 'tmp/myfile'
    new_filename = 'tmp/movedfile'
    old_path = Rails.root.join(old_filename)
    new_path = Rails.root.join(new_filename)

    FileUtils.touch(old_path)

    put "/#{old_filename}", params: { new_name: new_filename }

    assert_response :success
    assert File.exist?(new_path)
    assert !File.exist?(old_path)
  ensure
    FileUtils.rm_rf(old_path) if old_path&.exist?
    FileUtils.rm_rf(new_path) if new_path&.exist?
  end

  def test_delete_file
    file_to_delete = Rails.root.join('tmp/new_file_to_delete')
    FileUtils.touch(file_to_delete)
    assert File.exist?(file_to_delete)

    delete "/tmp/new_file_to_delete"

    assert_response :success
    assert !File.exist?(file_to_delete)
  ensure
    FileUtils.rm_rf(file_to_delete) if file_to_delete&.exist?
  end

  def test_upload
    filename = 'Gemfile'
    uploaded_filename = Rails.root.join('tmp', filename)
    assert !File.exist?(uploaded_filename)

    post '/tmp/', params: {
      file: Rack::Test::UploadedFile.new(filename, 'text/plain')
    }

    assert_response :success
    assert File.exist?(uploaded_filename)
  ensure
    FileUtils.rm_rf(uploaded_filename) if uploaded_filename&.exist?
  end

  def test_directory_browsing
    ENV['BASE_DIRECTORY'] = @temp_dir.to_s

    # Create test directory structure
    subdir = @temp_dir.join('subdirectory')
    FileUtils.mkdir_p(subdir)

    get '/subdirectory'

    assert_response :success
    assert_template :index
  end

  def test_file_download
    filename = 'Gemfile'
    get "/#{filename}?download=true"

    assert_response :success
    assert_equal 'application/octet-stream', response.content_type
    assert !response.body.include?('<pre>')
  end

  def test_duplicate_name_rejected
    old_filename = Rails.root.join('tmp/myfile.txt')
    duplicate_name = Rails.root.join('tmp/myfile_copy.txt')

    FileUtils.touch(old_filename)
    FileUtils.touch(duplicate_name)

    put "/tmp/myfile.txt", params: { new_name: 'tmp/myfile_copy.txt' }

    assert_response :conflict
  ensure
    FileUtils.rm_rf(old_filename) if old_filename&.exist?
    FileUtils.rm_rf(duplicate_name) if duplicate_name&.exist?
  end

  def test_rename_with_subdirectories
    file_path = Rails.root.join('tmp', 'subdir', 'myfile.txt')
    new_path = Rails.root.join('tmp', 'otherdir', 'file.txt')

    FileUtils.mkdir_p(file_path.parent)
    FileUtils.mkdir_p(new_path.parent)
    FileUtils.touch(file_path)

    put '/tmp/subdir/myfile.txt', params: { new_name: '/tmp/otherdir/file.txt' }

    assert_response :success
    assert File.exist?(new_path)
    assert !File.exist?(file_path)
  ensure
    FileUtils.rm_rf(Rails.root.join('tmp', 'subdir'))
    FileUtils.rm_rf(Rails.root.join('tmp', 'otherdir'))
  end
end
