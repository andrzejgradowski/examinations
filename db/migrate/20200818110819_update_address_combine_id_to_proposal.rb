class UpdateAddressCombineIdToProposal < ActiveRecord::Migration[5.2]
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
    province = current_row.province_name.empty? ? "" : "#{current_row.province_name}"
    district = current_row.district_name.empty? ? "" : "#{current_row.district_name}"
    commune = current_row.commune_name.empty? ? "" : "#{current_row.commune_name}"
    city = current_row.city_name.empty? ? "" : "#{current_row.city_name}"
    street = current_row.street_name.empty? ? "" : "#{current_row.street_name}"

    province_code = current_row.province_code.empty? ? "" : "#{current_row.province_code}"
    district_code = current_row.district_code.empty? ? "" : "#{current_row.district_code}"
    commune_code = current_row.commune_code.empty? ? "" : "#{current_row.commune_code}"
    city_code = current_row.city_code.empty? ? "" : "#{current_row.city_code}"
    street_code = current_row.street_code.empty? ? "" : "#{current_row.street_code}"

    postal = current_row.c_address_postal_code.empty? ? "" : "#{current_row.c_address_postal_code}"

    address = "#{province + " " + district + " " + commune + " " + city + " " + street + " " + postal}"

    unless address.delete(' ').empty? 
      puts '----------------------------------------------------'
      puts "#{address}"

      address_obj = ApiTerytAddress.new(q: "#{address}" ) 
      address_obj.request_for_collection
      address_hash = JSON.parse(address_obj.response.body)


      # if address_hash.fetch('items', {}).size == 1
      #   combine_id = address_hash.fetch('items', {}).first.fetch('combineId', '')
      #   puts "#{combine_id}"
      #   current_row.update_columns(address_combine_id: "#{combine_id}")
      if address_hash.fetch('items', {}).size > 0
        address_items_array = address_hash.fetch('items', {})

        selected = address_items_array.select{|value| value['provinceCode'] == "#{province_code}" && 
                                                      value['districtCode'] == "#{district_code}" &&
                                                      value['communeCode'] == "#{commune_code}" &&
                                                      value['cityCode'] == "#{city_code}" &&
                                                      value['streetCode'] == "#{street_code}" &&
                                                      value['postCode'] == "#{postal}" }

        if selected.size == 0
          puts '  ERROR selected.size == 0'
          puts "  current_row.id: #{current_row.id}"
          puts "  current_row.lives_in_poland: #{current_row.lives_in_poland}"
          puts '  address_hash:'
          puts address_hash
          puts '  address_items_array:'
          puts address_items_array
          puts '  selected:'
          puts selected
          #sleep 10
        else
          if selected.size > 1
            puts '  ERROR selected.size > 1'
            puts "  current_row.id: #{current_row.id}"
            puts "  current_row.lives_in_poland: #{current_row.lives_in_poland}"
            puts '  address_hash:'
            puts address_hash
            puts '  address_items_array:'
            puts address_items_array
            puts '  selected:'
            puts selected
            #sleep 10
          else
            combine_id = selected.first.fetch('combineId', '')
            puts "#{combine_id}"
            current_row.update_columns(address_combine_id: "#{combine_id}")
          end
        end
      else
        puts "NOT FOUND -> address_hash.fetch('items', {}).size = 0"
        puts "  current_row.id: #{current_row.id}"
        puts "  lives_in_poland: #{current_row.lives_in_poland}"
        #sleep 10
      end
      puts '----------------------------------------------------'
    end
  end

end
