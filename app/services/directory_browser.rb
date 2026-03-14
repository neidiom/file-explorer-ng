# frozen_string_literal: true

require 'uri'

# Service for browsing directory contents safely
class DirectoryBrowser
  DirectoryEntry = Struct.new(
    :name,
    :path,
    :type,
    :size,
    :modified_at,
    :relative_url,
    keyword_init: true
  )

  # List directory entries with metadata
  # @param path [String, Pathname] The directory path to list
  # @param base_url [String] The base URL for constructing relative URLs
  # @return [Array<DirectoryEntry>] List of directory entries
  def self.list(path:, base_url: '')
    path = Pathname.new(path).expand_path

    Dir
      .entries(path)
      .map { |name| build_entry(name, path + name, base_url) }
      .select(&:valid?)
      .sort_by { |entry| [entry.rank, entry.name] }
  end

  class << self
    private

    def build_entry(name, full_path, base_url)
      stat = full_path.stat

      DirectoryEntry.new(
        name: name,
        path: full_path.to_s,
        type: full_path.directory? ? :directory : :file,
        size: full_path.file? ? stat.size : nil,
        modified_at: stat.mtime,
        relative_url: build_url(base_url, name, full_path.directory?)
      )
    end

    def build_url(base_url, name, is_directory)
      uri = URI::DEFAULT_PARSER
      escaped = uri.escape("#{base_url}#{name}#{is_directory ? '/' : ''}")
      escaped.gsub('%2F', '/')
    end
  end
end

# Extend the DirectoryEntry struct with methods
class DirectoryBrowser::DirectoryEntry
  # Directories rank 0, files rank 1 for sorting
  def rank
    type == :directory ? 0 : 1
  end

  # Skip . and .. entries
  def valid?
    %w[. ..].exclude?(name)
  end

  def directory?
    type == :directory
  end

  def file?
    type == :file
  end

  def human_size
    return '-' unless file?

    ActiveSupport::NumberHelper.number_to_human_size(size, precision: 1)
  end

  def formatted_date
    modified_at.strftime('%d %b %Y %H:%M')
  end
end
