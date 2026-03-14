# frozen_string_literal: true

# Policy for file system operations authorization
class FileSystemPolicy
  ALLOWED_OPERATIONS = Set.new(%i[list read create update delete]).freeze

  class << self
    # Authorize an operation on the file system
    # @param user [Object] Current user (can be nil for anonymous access)
    # @param operation [Symbol] The operation to perform
    # @param path [Pathname, String] The path the operation targets
    # @return [Boolean] True if operation is allowed
    def authorize(user, operation, path = nil)
      return false unless ALLOWED_OPERATIONS.include?(operation)

      return true if operation == :list

      # For file operations, validate the path
      return true unless path

      validate_path!(path)
      true
    rescue ArgumentError
      false
    end

    # Validate that a path is safe
    # @param path [Pathname, String] The path to validate
    # @raise [ArgumentError] If path is invalid
    def validate_path!(path)
      pathname = path.is_a?(Pathname) ? path : Pathname.new(path)

      # Prevent directory traversal
      if pathname.to_s.include?('..')
        raise ArgumentError, 'Path contains invalid characters'
      end

      # Prevent null bytes
      if pathname.to_s.include?("\0")
        raise ArgumentError, 'Path contains null bytes'
      end
    end

    # Check if a file type is allowed
    # @param mime_type [String] The MIME type to check
    # @return [Boolean] True if type is allowed
    def allowed_mime_type?(mime_type)
      return true if mime_type.nil? || mime_type.empty?

      FileSystemSecurity::ALLOWED_MIME_TYPES.include?(mime_type)
    end
  end
end
