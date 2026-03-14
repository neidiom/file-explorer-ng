# frozen_string_literal: true

# Service for handling file uploads
class FileUploadService
  class << self
    # Upload a file to the specified directory
    # @param directory [Pathname] The target directory
    # @param file [ActionDispatch::Http::UploadedFile] The file to upload
    # @return [Pathname] The path where the file was saved
    def upload(directory:, file:)
      raise ArgumentError, 'No file provided' if file.nil?

      FileSystemOperations.upload(directory: directory, file: file)
    end
  end
end
