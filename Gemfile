source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.9'
# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.3.18'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
gem 'sorcery'

group :test, :development do
  #pry
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'

  # replaces the standard Rails error page with a much better and more useful error page
  gem 'better_errors'

  gem "quiet_assets"
end

#upload picture
gem 'paperclip'
gem "aws-sdk", "~> 1.6"

gem "rails-erd"

# for ENV in Rails
gem "figaro"

gem'exifr'

gem 'kaminari', :git => 'git@github.com:amatsuda/kaminari.git', :ref => '4b2121e7507d6760d35e5bfa8d2c716c95767af4'

gem "angular-rails-templates"

# annotate
gem "annotate"

source 'https://rails-assets.org' do
  gem "rails-assets-angular", "~> 1.4.7"
  gem "rails-assets-angular-animate"
  gem "rails-assets-angular-bootstrap"
  gem "rails-assets-angular-cookies"
  gem "rails-assets-angular-google-maps", "~> 2.2.1"
  gem "rails-assets-angular-resource"
  gem "rails-assets-angular-ui-router"
  gem "rails-assets-angular-selectize2", "~> 1.2.3"
  gem "rails-assets-angular-translate"
  gem "rails-assets-angular-translate-loader-static-files"
  gem "rails-assets-angular-translate-storage-cookie"
  gem "rails-assets-angular-ui-bootstrap"
  gem "rails-assets-angular-bootstrap-lightbox"
  gem "rails-assets-angular-touch" # added by dependence of lightbox
  gem "rails-assets-angular-loading-bar" # added by dependence of lightbox
  gem "rails-assets-bootstrap-sass", "3.3.4"
  gem "rails-assets-bootstrap-daterangepicker"
  gem "rails-assets-restangular"
  gem "rails-assets-lodash", "~>3.10.1"
  gem "rails-assets-jquery-file-upload", "9.11.2"
  gem "rails-assets-blueimp-load-image", "1.14.0"
  gem "rails-assets-jquery", "~> 2.1"
  gem "rails-assets-jquery-ui"
  gem "rails-assets-moment"
end

gem 'foursquare2'

# add task to queue
gem 'delayed_job_active_record'

# run daemon to execute queued task
gem 'daemons'

group :test, :development do
  # for test
  gem 'rspec-rails'
  gem 'rspec-core'
  gem 'factory_girl_rails'
end
