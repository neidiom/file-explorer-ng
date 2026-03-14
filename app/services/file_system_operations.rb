# frozen_string_literal: true

# Service for file system operations with size limits and validation
class FileSystemOperations
  MAX_FILE_SIZE = 100.megabytes
  ALLOWED_MIME_TYPES = Set.new([
    'text/plain',
    'text/html',
    'text/css',
    'text/javascript',
    'application/json',
    'application/xml',
    'application/octet-stream',
    'text/x-ruby'
  ]).freeze

  class << self
    # Upload a file to a directory
    # @param directory [Pathname] Target directory
    # @param file [ActionDispatch::Http::UploadedFile] The file to upload
    # @raise [ArgumentError] If directory is not a Pathname
    # @raise [ArgumentError] If file is too large
    # @raise [ActionController::ForbiddenError] If file type is not allowed
    def upload(directory:, file:)
      raise ArgumentError, 'Invalid path' unless directory.is_a?(Pathname)
      raise ArgumentError, 'File too large' if file.size > MAX_FILE_SIZE

      validate_mime_type!(file)

      target_path = directory + file.original_filename
      File.write(target_path, file.read, mode: 'wb')

      target_path
    end

    # Delete a file or directory
    # @param path [Pathname] Path to delete
    def delete(path)
      if path.directory?
        FileUtils.rm_rf(path)
      else
        FileUtils.rm(path)
      end
    end

    # Rename/move a file or directory
    # @param from [Pathname] Source path
    # @param to [Pathname] Destination path
    def rename(from:, to:)
      # Create parent directories if they don't exist
      parent = to.parent
      FileUtils.mkdir_p(parent) unless parent.exist? || parent == to.parent.parent

      FileUtils.mv(from, to)
    end

    private

    def validate_mime_type!(file)
      # Allow if no content type is present (browser may not send it)
      return unless file.content_type

      mime_type = file.content_type
      unless ALLOWED_MIME_TYPES.include?(mime_type)
        raise ActionController::ForbiddenError,
              "File type '#{mime_type}' is not allowed"
      end
    end
  end
end
