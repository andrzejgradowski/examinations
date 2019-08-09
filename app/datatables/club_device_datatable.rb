class ClubDeviceDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    @view_columns ||= {
      id:                 { source: "ClubDevice.id" },
      number:             { source: "ClubDevice.number", cond: :like, searchable: true, orderable: true },
      valid_to:           { source: "ClubDevice.valid_to" },
      call_sign:          { source: "ClubDevice.call_sign" },
      category:           { source: "ClubDevice.category" },
      transmitter_power:  { source: "ClubDevice.transmitter_power" },
      name_type_station:  { source: "ClubDevice.name_type_station" },
      emission:           { source: "ClubDevice.emission" },
      input_frequency:    { source: "ClubDevice.input_frequency" },
      output_frequency:   { source: "ClubDevice.output_frequency" },
      station_city:       { source: "ClubDevice.station_city" },
      applicant_name:     { source: "ClubDevice.applicant_name" }
    }
  end

  def data
    records.map do |record|
      {
        id:                 record.id,
        number:             record.number_as_link(params[:locale]),
        valid_to:           record.valid_to,
        call_sign:          record.call_sign,
        category:           record.category,
        transmitter_power:  record.transmitter_power,
        name_type_station:  record.name_type_station,
        emission:           record.emission,
        input_frequency:    record.input_frequency,
        output_frequency:   record.output_frequency,
        station_city:       record.station_city,
        applicant_name:     record.applicant_name
      }
    end
  end

  def get_raw_records
    # insert query here
    ClubDevice.all
  end

end

