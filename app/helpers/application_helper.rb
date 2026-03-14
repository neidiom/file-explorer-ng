# frozen_string_literal: true

module ApplicationHelper
  # Helper for generating file icons
  def file_icon_class(extension)
    {
      'rb' => 'fa-file-code',
      'md' => 'fa-file',
      'txt' => 'fa-file-text',
      'json' => 'fa-file-code',
      'xml' => 'fa-file-code',
      'css' => 'fa-file-code',
      'js' => 'fa-file-code',
      'html' => 'fa-file-code'
    }[extension.downcase] || 'fa-file'
  end
end
