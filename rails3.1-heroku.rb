puts "-----------------------------------------------------------------------"
puts "Rails Application Template for Heroku Cedar"
puts "-----------------------------------------------------------------------"

app_name = ask("What do you want to call your Heroku app?")

puts "-----------------------------------------------------------------------"
puts "Remove unneeded files"
puts "-----------------------------------------------------------------------"
run 'rm public/index.html'
run 'rm app/assets/images/rails.png'
run 'rm README'
run 'touch README'

puts "-----------------------------------------------------------------------"
puts "Create Gemfile"
puts "-----------------------------------------------------------------------"
run 'rm Gemfile'
create_file 'Gemfile', <<HERE
source 'http://rubygems.org'
gem 'rails', '3.2.6'
gem 'thin'
gem 'pg'
gem 'jquery-rails'
gem 'friendly_id', '4.0.7'

group :assets do
  gem 'less-rails', '2.2.0'
  gem 'uglifier', '1.2.2'
end

group :development do
	gem 'mysql2'
end
HERE

puts "-----------------------------------------------------------------------"
puts "Create Procfile"
puts "-----------------------------------------------------------------------"
create_file 'Procfile', "web: bundle exec rails server thin -p $PORT"

puts "-----------------------------------------------------------------------"
puts "Create database config"
puts "-----------------------------------------------------------------------"
run 'rm config/database.yml'
create_file 'config/database.yml', <<HERE
development:
  adapter: mysql2
  database: #{app_name}_development
  username: root
  password:
  host: localhost
  socket: /tmp/mysql.sock
  encoding: utf8
  
test:
  adapter: mysql2
  database: #{app_name}_test
  username: root
  password:
  host: localhost
  socket: /tmp/mysql.sock
  encoding: utf8
    
HERE

puts "-----------------------------------------------------------------------"
puts "Setup database"
puts "-----------------------------------------------------------------------"
rake "db:create"

puts "-----------------------------------------------------------------------"
puts "Get Skeleton"
puts "-----------------------------------------------------------------------"
run "cd app/assets/stylesheets"
run "curl https://raw.github.com/dhgamache/Skeleton/master/stylesheets/base.css -o app/assets/stylesheets/base.css"
run "curl https://raw.github.com/dhgamache/Skeleton/master/stylesheets/layout.css -o app/assets/stylesheets/layout.css"
run "curl https://raw.github.com/dhgamache/Skeleton/master/stylesheets/skeleton.css -o app/assets/stylesheets/skeleton.css"

puts "-----------------------------------------------------------------------"
puts "Commit to git"
puts "-----------------------------------------------------------------------"
append_file '.gitignore' do
  '.DS_Store'
end
git :init
git :add => '.'
git :commit => "-m 'Initial commit of Rails app for Heroku Cedar'"

puts "-----------------------------------------------------------------------"
puts "Create Heroku app"
puts "-----------------------------------------------------------------------"
run "heroku create #{app_name} --stack cedar"

puts "-----------------------------------------------------------------------"
puts "Push to Heroku"
puts "-----------------------------------------------------------------------"
run "git push heroku master"

puts "-----------------------------------------------------------------------"
puts "Setup Pow"
puts "-----------------------------------------------------------------------"
run "ln -s #{destination_root} ~/.pow/#{app_name}"
run "open http://#{app_name}.dev/"