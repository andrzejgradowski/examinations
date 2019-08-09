class ClubDatatable < AjaxDatatablesRails::ActiveRecord

  def view_columns
    @view_columns ||= {
      id:                 { source: "Club.id" },
      number:             { source: "Club.number", cond: :like, searchable: true, orderable: true },
      valid_to:           { source: "Club.valid_to" },
      call_sign:          { source: "Club.call_sign" },
      category:           { source: "Club.category" },
      transmitter_power:  { source: "Club.transmitter_power" },
      station_city:       { source: "Club.station_city" },
      applicant_name:     { source: "Club.applicant_name" }
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
        station_city:       record.station_city,
        applicant_name:     record.applicant_name
      }
    end
  end

  def get_raw_records
    # insert query here
    Club.all
  end

end

