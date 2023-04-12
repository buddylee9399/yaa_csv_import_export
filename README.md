# Introduction to Importing from CSV in Rails
- https://www.youtube.com/watch?v=mTnsUyLuPgY&pp=ygUMZ28gcmFpbHMgY3N2
- add to app.rb
```
require 'csv'
require "rails/all"
```
- restart server
- create the file at root: users.csv
```
user1@ex.com,user,one
user2@ex.com,user,two
```
- sidenote: accessing files in the directory
```
if we need to acess a file in the root 
in rails c
Rails.root
File.join Rails.root, 'users.csv'
```
- create the file lib/tasks/import.rake
```
namespace :import do
	desc 'Import users from csv'
	filename = File.join Rails.root, 'users.csv'
	CSV.foreach(filename) do |row|
		p row
	# p row.to_hash					
	end
end
```
- in terminal: 
```
rails import:users
or
bundle exec rake import:users
```

- we see the output of the file
- printing a file with headers
- create the user_header.csv
```
Email,First Name, Last Name
user1@ex.com,user,one
user2@ex.com,user,two
```

- update the import.rake
```
namespace :import do
	desc 'Import users from csv'
	# filename = File.join Rails.root, 'users.csv'
	filename = File.join Rails.root, 'user_header.csv'
	# CSV.foreach(filename) do |row|
	CSV.foreach(filename, headers: true) do |row|
		p row
	# p row.to_hash					
		p row["Email"]
	end
end
```
- importing the file
- rails g scaffold User email first_name last_name
- rails db:migrate
- update the import.rake without headers
```
namespace :import do
	desc 'Import users from csv'
	task users: :environment do
		filename = File.join Rails.root, 'users.csv'
		# filename = File.join Rails.root, 'user_header.csv'
		counter = 0
		CSV.foreach(filename) do |row|
		# CSV.foreach(filename, headers: true) do |row|
			email, first, last = row
			user = User.create(email: email, first_name: first, last_name: last)
			puts "#{email} - #{user.errors.full_messages.join(",")}" if user.errors.any?
			counter += 1 if user.persisted?
			# p row
			# p row.to_hash						
			# p row["Email"]
		end
		puts "Imported #{counter} users"
	end
end
```
- in terminal: rails import:users
- 2 imported
- importing with headers
- update the import.rake file
```
namespace :import do
	desc 'Import users from csv'
	task users: :environment do
		# filename = File.join Rails.root, 'users.csv'
		filename = File.join Rails.root, 'user_header.csv'
		counter = 0
		# CSV.foreach(filename) do |row|
		CSV.foreach(filename, headers: true) do |row|
			# email, first, last = row
			user = User.create(email: row["Email"], first_name: row["First Name"], last_name: row["Last Name"])
			puts "#{email} - #{user.errors.full_messages.join(",")}" if user.errors.any?
			counter += 1 if user.persisted?
			# p row
			# p row.to_hash			
			# p row["Email"]
		end
		puts "Imported #{counter} users"
	end
end
```
- in terminal: rails import:users
- 2 imported

# Export Records to CSV with Ruby on Rails
- https://www.youtube.com/watch?v=H3pjCJSLCgc&pp=ygUMZ28gcmFpbHMgY3N2
- update routes
```
root "users#index"
```

- update the users controller
```
  def index
    @users = User.all
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv}
    end
  end
```

- sidenote *** how to use .attributes
```
in rails c: User.last.attributes.values_at("id", "email")
attributes = %w{id email first_name last_name}
User.last.attributes.values_at(*attributes)
=  [14, "user4@ex.com", "user", "four"]
```
- update user.rb model
```
class User < ApplicationRecord
	validates :email, presence: true

	def self.to_csv
		attributes = %w{id email first_name last_name}
		CSV.generate(headers: true) do |csv|
			csv << attributes
			# p csv
			all.each do |user|
				# p user.attributes.values_at(*attributes)
				csv << user.attributes.values_at(*attributes)
			end
		end
	end
end

```
- go to localhost:3000/users.csv
- IT WORKED
- if there is a method in the model that concatenates 2 fields then update the model like this

```
	def name
		"#{first_name} #{last_name}"
	end
```
- test in rails c, with the 'send' method
```
u = User.last
u.send "name"
```
- update the csv method in the model
```
class User < ApplicationRecord
	validates :email, presence: true

	def name
		"#{first_name} #{last_name}"
	end
	def self.to_csv
		attributes = %w{id email first_name last_name}
		# attributes = %w{id email name}

		CSV.generate(headers: true) do |csv|
			csv << attributes
			# p csv
			all.each do |user|
				# p user.attributes.values_at(*attributes)
				csv << user.attributes.values_at(*attributes)
				# csv << attributes.map { |attr| puts attr}
				# using with the name method
				# csv << attributes.map { |attr| user.send(attr)}
			end
		end
	end
end
```
- go to localhost:3000/users.csv
- we should se the field as name, and the first and last name concatenated
- IT WORKED
- updating the filename
- update the users controller
```
  def index
    @users = User.all
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv, filename: "user-#{Date.today}.csv"}
    end
  end
```

# Ruby on Rails - Railscasts #362 Exporting Csv And Excel
- he did the same, showed how to do a version of xls

# Ruby on Rails - Railscasts #396 Importing Csv And Excel
- same as hudgens, but did a version to allow for updating of the csv file, but i didnt do it

```
	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			User.create! row.to_hash
			# users = find_by_id(row["id"]) || new
			# users.attributes = row.to_hash.slice(*accessible_attributes)
		end
	end
```
- added a gem to do the xls spareadsheet, i didnt do it

# Ruby on Rails #88 Import CSV and parse it within a Rails app
- added a validation at the controller
- update users controller
- the User.import is commented out just to test out the unless
```
  def import
    return redirect_to users_path, notice: 'Only CSV please' unless params[:file].content_type == 'text/csv'
    # User.import(params[:file])
    redirect_to root_url, notice: "Users imported"
  end
```
- added the validation to the form file field itself
```
<%= form_tag import_users_path, multipart: true do %>
  <%= file_field_tag :file, accept: '.csv' %>
  <%= submit_tag "Upload Users" %>
<% end %>
```
- create the folder app/services
- create the file: csv_import_users_service.rb
```
class CsvImportUsersService
	def call(file)
		file = File.open(file)
		csv = CSV.parse(file, headers: true)
		csv.each do |row|
			# p row
			user_hash = {}
			user_hash[:email] = row['email']
			user_hash[:first_name] = row['first_name']
			user_hash[:last_name] = row['last_name']
			# binding.irb
			User.create(user_hash)
			# p user_hash[:email]
			p row
		end
	end
end
```
- update the users_controlelr
```
  def import
    file = params[:file]
    return redirect_to users_path, notice: 'Only CSV please' unless file.content_type == 'text/csv'
    # User.import(file')
    CsvImportUsersService.new.call(file)
    redirect_to root_url, notice: "Users imported"
  end
```

# Ruby on Rails #89 export to CSV (different approaches)
- did the same as go rails
- extracted the .to_csv from the model and created a concern to other models can use it
- create the file app/models/concerns/generate_csv.rb
```
module GenerateCsv
  extend ActiveSupport::Concern

  class_methods do
    def to_csv(collection)
    
      # attributes = %w{id email first_name last_name}
      # p "The attributes are #{attributes}"
      # p "The attribute names are " + attribute_names.to_s
      # attributes = %w{id email name}

      CSV.generate(headers: true) do |csv|
        csv << attribute_names
        # p csv
        collection.each do |record|
          csv << record.attributes.values
          # p user.attributes.values_at(*attributes)
          # csv << user.attributes.values_at(*attributes)
          # csv << attributes.map { |attr| puts attr}
          # using with the name method
          # csv << attributes.map { |attr| user.send(attr)}
        end
      end
    end    
  end
end
```
- update users controller
```
  def index
    @users = User.all
    respond_to do |format|
      format.html
      # format.csv { render json: @users.to_csv }
      # format.csv { send_data @users.to_csv, filename: "user-#{Date.today}.csv" }
      format.csv { send_data User.to_csv(@users), filename: "user-#{Date.today}.csv" }
    end
  end
```

- add to user.rb
```
class User < ApplicationRecord
	validates :email, presence: true
	include GenerateCsv
```
- restart server
- test
- IT WORKED

# Episode #035 - Importing and Exporting CSV Data
- IMPORTING
- require 'csv' to app.rb
- in the post controller

```
  def index
    @posts = Post.all
    respond_to do |format|
      format.html
      # format.csv { render json: @users.to_csv }
      # format.csv { send_data @users.to_csv, filename: "user-#{Date.today}.csv" }
      format.csv { send_data Post.to_csv(@posts), filename: "post-#{Date.today}.csv" }
    end    
  end
```

- updating the 