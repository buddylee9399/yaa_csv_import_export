# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  first_name :string
#  last_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
	validates :email, presence: true
	include GenerateCsv

	def name
		"#{first_name} #{last_name}"
	end

	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			User.create! row.to_hash
			# users = find_by_id(row["id"]) || new
			# users.attributes = row.to_hash.slice(*accessible_attributes)
		end
	end

	# from drifting ruby #35
	# def self.to_csv(fields = column_names, options = {})
	# 	CSV.generate() do |csv|
	# 		# binding.irb
	# 		csv << fields
	# 		all.each do |user|
	# 			csv << user.attributes.values_at(*fields)
	# 		end
	# 	end
	# end

	# def self.to_csv
	
	# 	attributes = %w{id email first_name last_name}
	# 	p "The attributes are #{attributes}"
	# 	p "The attribute names are " + attribute_names.to_s
	# 	# attributes = %w{id email name}

	# 	CSV.generate(headers: true) do |csv|
	# 		csv << attributes
	# 		# p csv
	# 		all.each do |user|
	# 			# p user.attributes.values_at(*attributes)
	# 			csv << user.attributes.values_at(*attributes)
	# 			# csv << attributes.map { |attr| puts attr}
	# 			# using with the name method
	# 			# csv << attributes.map { |attr| user.send(attr)}
	# 		end
	# 	end
	# end
end
