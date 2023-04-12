namespace :import do
	desc 'Import users from csv'
	task users: :environment do
		# filename = File.join Rails.root, 'users.csv'
		# filename = File.join Rails.root, 'user_header.csv'
		filename = File.join Rails.root, 'excel_users.csv'
		counter = 0
		# CSV.foreach(filename) do |row|
		# arr = []
		CSV.foreach(filename, headers: true) do |row|
			# email, first, last = row

			user = User.create(email: row["Email"], first_name: row["First Name"], last_name: row["Last Name"])
			puts "#{email} - #{user.errors.full_messages.join(",")}" if user.errors.any?
			counter += 1 if user.persisted?
			# arr << row.to_hash

			# p row
			# p row.to_hash
			# p row["First Name"]
		end
		# puts arr
		# puts arr[0]["Email"]
		puts "Imported #{counter} users"
	end
end