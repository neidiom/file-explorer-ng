# frozen_string_literal: true

require 'action_support/number_helper'

# Value object representing a file or directory entry
class DirectoryEntry
  include ActiveSupport::NumberHelper

  attr_reader :name, :path, :type, :size, :modified_at, :relative_url

  IGNORED_ENTRIES = Set.new(['.', '..']).freeze

  def initialize(name:, path:, type:, size: nil, modified_at:, relative_url:)
    @name = name
    @path = path
    @type = type
    @size = size
    @modified_at = modified_at
    @relative_url = relative_url
  end

  def directory?
    @type == :directory
  end

  def file?
    @type == :file
  end

  def ignored?
    IGNORED_ENTRIES.include?(@name)
  end

  # Directories rank 0, files rank 1 for sorting
  def rank
    directory? ? 0 : 1
  end

  def human_size
    return '-' unless file?

    number_to_human_size(@size, precision: 1)
  end

  def formatted_date
    @modified_at.strftime('%d %b %Y %H:%M')
  end

  def icon_class
    directory? ? 'fa-folder' : 'fa-file'
  end

  def display_name
    "#{@name}#{directory? ? '/' : ''}"
  end
end
