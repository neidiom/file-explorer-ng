# frozen_string_literal: true

# Validates that paths are within allowed directory bounds
class PathSecurityValidator
  VALIDATE_PATH_ERROR = 'Invalid path: outside allowed directory'.freeze

  class << self
    def validate(path, base_directory)
      expanded = Pathname.new(path).expand_path(base_directory)
      base = Pathname.new(base_directory).expand_path

      raise ActionController::ForbiddenError, VALIDATE_PATH_ERROR unless
        expanded.to_s.start_with?(base.to_s)

      expanded
    end
  end
end
