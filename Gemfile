source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in file-explorer-ng.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.

rails_root = ENV['RAILS_ROOT'] || File.expand_path('..', __dir__)
rails_version = ENV['RAILS_VERSION'] || '7.2.2'

gem 'rails', rails_version
# Use Puma as the app server
gem 'puma', '~> 6.4'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 4.2.0', require: false
gem 'font-awesome-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

gem 'bootsnap', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 4.0'
  gem 'listen', '~> 3.9'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1'
  debug
end

group :test do
  gem 'rails-controller-testing'
end
