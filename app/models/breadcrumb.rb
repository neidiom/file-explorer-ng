# frozen_string_literal: true

# Value object representing a breadcrumb navigation item
class Breadcrumb
  attr_reader :url, :name

  def initialize(url, name)
    @url = url
    @name = name
  end

  def last?(breadcrumbs)
    breadcrumbs.last == self
  end
end
