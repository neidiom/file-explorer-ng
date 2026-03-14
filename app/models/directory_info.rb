# frozen_string_literal: true

require 'action_view/helpers/number_helper'

# Value object representing a directory view with its entries and breadcrumbs
class DirectoryInfo
  include ActionView::Helpers::NumberHelper

  ROOT_LABEL = 'root'.freeze

  attr_reader :display_path, :entries, :requested_path, :parent_path

  # @param path [String, Pathname] The file system path to this directory
  # @param request_path [String] The path from the request (relative path)
  # @param base_url [String] The base URL for constructing links
  def initialize(path, request_path: '', base_url: '')
    @path = Pathname.new(path).expand_path
    @requested_path = request_path
    @base_url = base_url
    @display_path = format_display_path(request_path)
    @parent_path = calculate_parent_path(request_path)
    @entries = load_entries
  end

  def breadcrumbs
    return [Breadcrumb.new('/', ROOT_LABEL)] if @requested_path.empty?

    components = @requested_path.split('/')
    components.each_with_index.map do |component, index|
      join_path = components[0..index].join('/')
      Breadcrumb.new("/#{join_path}", component)
    end
  end

  def root?
    @requested_path.empty?
  end

  def full_path
    @path.to_s
  end

  private

  def load_entries
    DirectoryBrowser.list(path: @path, base_url: "#{@base_url}#{@requested_path}")
  end

  def format_display_path(path)
    path.empty? ? ROOT_LABEL : path
  end

  def calculate_parent_path(request_path)
    return nil if request_path.empty? || !request_path.include?('/')

    components = request_path.split('/')
    components[0..-2].join('/')
  end
end
