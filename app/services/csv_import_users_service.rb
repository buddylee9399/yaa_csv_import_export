class CsvImportUsersService
	# def call(file)
	# 	file = File.open(file)
	# 	csv = CSV.parse(file, headers: true)
	# 	csv.each do |row|
	# 		# p row
	# 		user_hash = {}
	# 		user_hash[:email] = row['email']
	# 		user_hash[:first_name] = row['first_name']
	# 		user_hash[:last_name] = row['last_name']
	# 		# binding.irb
	# 		User.create(user_hash)
	# 		# p user_hash[:email]
	# 		# p row
	# 	end
	# end

	# from drifting ruby #35
	def call(file)
			# binding.irb
		CSV.foreach(file.path, headers: true) do |row|
			user_hash = row.to_hash
			user = User.find_or_create_by!(email: user_hash["email"])
			user.update(user_hash)
		end
	end
end