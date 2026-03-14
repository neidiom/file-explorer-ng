# frozen_string_literal: true

require 'pathname'

# Controller for managing file browsing and operations
class IndexController < ApplicationController
  include FileSystemSecurity

  BASE_DIRECTORY = Pathname.new(ENV.fetch('BASE_DIRECTORY', '.'))
  MAX_INLINE_DISPLAY_SIZE = 1.megabyte

  before_action :set_base_url
  before_action :validate_base_directory

  # GET /
  # Display root directory listing
  def index
    @directory_info = DirectoryInfo.new(
      BASE_DIRECTORY,
      request_path: '',
      base_url: @base_url
    )
    render :index
  end

  # POST /
  # Upload file to root directory
  def upload_index
    upload_file_to(BASE_DIRECTORY)
    redirect_to action: :index
  end

  # GET /:path
  # Display directory content or file content based on path
  def show
    path = validate_and_resolve_path(params[:path])

    if path.directory?
      @directory_info = DirectoryInfo.new(
        path,
        request_path: params[:path],
        base_url: @base_url
      )
      render :index
    else
      display_file(path, params[:download])
    end
  end

  # POST /:path
  # Upload file to specified directory
  def upload
    path = validate_and_resolve_path(params[:path])
    raise ForbiddenError unless path.directory?

    upload_file_to(path)
    redirect_to action: :show, path: params[:path]
  end

  # DELETE /:path
  # Delete file or directory at specified path
  def destroy
    path = validate_and_resolve_path(params[:path])
    FileDeletionService.delete(path)

    head :no_content
  end

  # PUT /:path
  # Rename/move file or directory
  def update
    source = validate_and_resolve_path(params[:path])
    destination = validate_and_resolve_path(params[:new_name])

    if destination.exist?
      head :conflict
    else
      FileOperationService.rename(from: source, to: destination)
      head :no_content
    end
  end

  private

  # Display file content or trigger download
  def display_file(path, force_download)
    if force_download || path.size > MAX_INLINE_DISPLAY_SIZE
      send_file(path.to_s, disposition: :attachment)
    else
      @file_content = path.read
      render :file, formats: :html
    end
  end

  # Upload a file to a directory
  def upload_file_to(directory)
    raise ForbiddenError unless directory.directory?

    file = params[:file]
    return if file.nil?

    target_path = directory + file.original_filename
    validate_operation_allowed(target_path)

    FileUploadService.upload(directory: directory, file: file)
  end

  # Set the base URL for display
  def set_base_url
    @base_url = ENV.fetch('BASE_URL', 'root')
  end

  # Validate that the base directory exists and is accessible
  def validate_base_directory
    return if BASE_DIRECTORY.directory? && BASE_DIRECTORY.readable? && BASE_DIRECTORY.executable?

    raise RuntimeError, "Base directory '#{BASE_DIRECTORY}' is not accessible"
  end
end
