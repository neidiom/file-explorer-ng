# frozen_string_literal: true

# Service for handling file and directory deletion
class FileDeletionService
  class << self
    # Delete a file or directory at the given path
    # @param path [Pathname] The path to delete
    def delete(path)
      raise ArgumentError, 'Path does not exist' unless path.exist?

      FileSystemOperations.delete(path)
    end
  end
end
