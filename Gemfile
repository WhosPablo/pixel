source 'https://rubygems.org'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use react as the JavaScript library
gem 'react-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Used to implement at.js for auto complete mentions
gem 'jquery-atwho-rails'

# Use twitter bootstrap sass
gem 'bootstrap-sass', '~> 3.3.7'
gem 'autoprefixer-rails'
gem 'font-awesome-rails'


gem 'google-api-client'

# Be able to follow people
gem 'acts_as_follower', '~> 0.2.0'

# Devise for user authentication
gem 'devise'
gem 'omniauth-google-oauth2'


# Votable and commentable questions
gem 'acts_as_votable', '~> 0.10.0'
gem 'acts_as_commentable'

# Easy forms
gem 'simple_form'

# Google material design
gem 'material_design_lite-rails', '~> 1.2'

gem 'public_activity'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'guard'
  gem 'guard-rspec', '~> 4.7.3'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'sqlite3'
end

group :production do
  # Use postgresql as the database for Active Record
  gem 'pg', '~> 0.18'
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'fog'
  gem 'fog-aws'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

ruby '2.3.1'
