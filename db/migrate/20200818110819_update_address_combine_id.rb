class UpdateAddressCombineId < ActiveRecord::Migration[5.2]
  def up
    Proposal.where(address_combine_id: '', lives_in_poland: true).each do |rec|
      set_data_into_address_combine_id(rec)
    end
  end

  def down
    Proposal.where.not(address_combine_id: '').each do |rec|
      rec.update_columns(address_combine_id: '')
    end
  end

  def set_data_into_address_combine_id(current_row)
    province = current_row.province_name.empty? ? "" : "#{current_row.province_name} "
    district = current_row.district_name.empty? ? "" : "#{current_row.district_name} "
    commune = current_row.commune_name.empty? ? "" : "#{current_row.commune_name} "
    city = current_row.city_name.empty? ? "" : "#{current_row.city_name} "
    street = current_row.street_name.empty? ? "" : "#{current_row.street_name} "
    postal = current_row.c_address_postal_code.empty? ? "" : "#{current_row.c_address_postal_code}"

    address = "#{province + district + commune + city + street + postal}"

    unless address.empty? 
      puts '----------------------------------------------------'
      puts "#{address}"

      address_obj = ApiTerytAddress.new(q: "#{address}" ) 
      address_obj.request_for_collection
      address_hash = JSON.parse(address_obj.response.body)

      puts address_hash
      puts address_hash.fetch('items', {}).size

      if address_hash.fetch('items', {}).size == 1
        combine_id = address_hash.fetch('items', {}).first.fetch('combineId', '')
        puts "#{combine_id}"
        current_row.update_columns(address_combine_id: "#{combine_id}")
      end
      puts '----------------------------------------------------'
    end
  end

end
