# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

# Use specific branch of Rails
gem 'rails', github: 'rails/rails', branch: '7-1-stable'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.5'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.4'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
gem 'kredis', '~> 1.7'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# https://github.com/cyu/rack-cors
# config/initializers/cors.rb
# gem "rack-cors", '~> 2.0', '>= 2.0.1'

gem 'sidekiq', '~> 7.2'

gem 'clockwork', '~> 3.0', '>= 3.0.2'

gem 'faraday', '~> 2.9'
gem 'faraday-retry', '~> 2.2'

gem 'activerecord-import', '~> 1.5', '>= 1.5.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'dotenv-rails', '~> 2.8', '>= 2.8.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'rspec-rails', '~> 6.1'
  gem 'rubocop', '~> 1.59'
  gem 'rubocop-rspec', '~> 2.25.0'
  gem 'shoulda-matchers', '~> 6.0'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'webmock', '~> 3.19'
end
