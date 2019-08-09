class IndividualDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    @view_columns ||= {
      id:                 { source: "Individual.id" },
      number:             { source: "Individual.number", cond: :like, searchable: true, orderable: true },
      valid_to:           { source: "Individual.valid_to" },
      call_sign:          { source: "Individual.call_sign" },
      category:           { source: "Individual.category" },
      transmitter_power:  { source: "Individual.transmitter_power" },
      station_location:   { source: "Individual.station_location" }
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
        station_location:   record.station_location
      }
    end
  end

  def get_raw_records
    # insert query here
    Individual.all
  end

end
