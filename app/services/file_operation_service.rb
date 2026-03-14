# frozen_string_literal: true

# Service for file move/rename operations
class FileOperationService
  class << self
    # Rename or move a file or directory
    # @param from [Pathname] Source path
    # @param to [Pathname] Destination path
    # @raise [ArgumentError] If source doesn't exist
    # @raise [ActionController::Conflict] If destination exists
    def rename(from:, to:)
      raise ArgumentError, 'Source does not exist' unless from.exist?

      if to.exist?
        raise ActionController::BadRequest, 'Destination already exists'
      end

      FileSystemOperations.rename(from: from, to: to)
    end
  end
end
