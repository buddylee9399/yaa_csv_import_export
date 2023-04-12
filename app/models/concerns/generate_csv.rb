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