# frozen_string_literal: true

# Security concerns for file system operations
module FileSystemSecurity
  # File size limits
  MAX_FILE_SIZE = 100.megabytes
  MAX_DIRECTORY_SIZE = 10.gigabytes

  # Allowed file types
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

  extend ActiveSupport::Concern

  included do
    before_action :verify_request_size
  end

  private

  def validate_and_resolve_path(user_path)
    resolved = Pathname.new(base_directory) + user_path.to_s
    PathSecurityValidator.validate(resolved, base_directory)
  end

  def safe_expand_path(path)
    Pathname.new(path).expand_path(base_directory)
  end

  def base_directory
    @base_directory ||= Pathname.new(ENV.fetch('BASE_DIRECTORY', '.'))
  end

  def verify_request_size
    return if request.content_length.nil?
    return if request.content_length <= MAX_FILE_SIZE

    raise ActionController::BadRequest, 'Request entity too large'
  end

  def validate_operation_allowed(path)
    # Validate that operations are allowed on this path
    raise ActionController::ForbiddenError, 'Path is outside allowed directory' unless
      path.to_s.start_with?(base_directory.to_s)
  end
end
