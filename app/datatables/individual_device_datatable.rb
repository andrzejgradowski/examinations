class IndividualDeviceDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    @view_columns ||= {
      id:                 { source: "IndividualDevice.id" },
      number:             { source: "IndividualDevice.number", cond: :like, searchable: true, orderable: true },
      valid_to:           { source: "IndividualDevice.valid_to" },
      call_sign:          { source: "IndividualDevice.call_sign" },
      category:           { source: "IndividualDevice.category" },
      transmitter_power:  { source: "IndividualDevice.transmitter_power" },
      name_type_station:  { source: "IndividualDevice.name_type_station" },
      emission:           { source: "IndividualDevice.emission" },
      input_frequency:    { source: "IndividualDevice.input_frequency" },
      output_frequency:   { source: "IndividualDevice.output_frequency" },
      station_location:   { source: "IndividualDevice.station_location" }
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
        station_location:   record.station_location
      }
    end
  end

  def get_raw_records
    # insert query here
    IndividualDevice.all
  end

end
