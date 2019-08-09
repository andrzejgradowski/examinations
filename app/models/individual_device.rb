require 'csv'
class IndividualDevice < ApplicationRecord
  delegate :url_helpers, to: 'Rails.application.routes'

  def number_as_link( loc )
    "<a href=#{url_helpers.individual_device_path(self.id, locale: loc)}>#{self.number}</a>".html_safe
  end

  # rubocop:disable MethodLength
  def self.to_csv
    CSV.generate(headers: false, col_sep: ';', converters: nil, skip_blanks: false, force_quotes: false) do |csv|
      columns_header = %w(number valid_to call_sign category transmitter_power name_type_station emission
                          input_frequency output_frequency station_location)
      csv << columns_header
      all.each do |rec|
        csv << [rec.number.strip,
                rec.valid_to,
                rec.call_sign,
                rec.category,
                rec.transmitter_power,
                rec.name_type_station,
                rec.emission,
                rec.input_frequency,
                rec.output_frequency,
                rec.station_location]
      end
    end.encode('WINDOWS-1250')
  end

  def self.load_from_pwid(doc)
    #IndividualDevice.destroy_all
    ActiveRecord::Base.connection.execute("TRUNCATE individual_devices RESTART IDENTITY")
    doc.xpath("//*[local-name()='wyszukajPozwoleniaBezobslugoweResponse']").each do |resp|
      resp.xpath("./*[local-name()='return']").each do |ret|
        ret.xpath("./*[local-name()='pozwolenie']").each do |pozwol|

          if pozwol.xpath("./*[local-name()='status']").text == 'Aktualna' && pozwol.xpath("./*[local-name()='wnioskodawca']").xpath("./*[local-name()='fizyczny']").text == 'true'

            #sleep 0.25

            IndividualDevice.create(
              number:             pozwol.xpath("./*[local-name()='sygnaturaEsod']").text.present? ? pozwol.xpath("./*[local-name()='sygnaturaEsod']").text : pozwol.xpath("./*[local-name()='numer']").text,
              date_of_issue:      pozwol.xpath("./*[local-name()='waznaOd']").text,
              valid_to:           pozwol.xpath("./*[local-name()='waznaDo']").text,
              call_sign:          pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='znak']").text,
              category:           pozwol.xpath("./*[local-name()='wniosek']").xpath("./*[local-name()='kategoria']").text,
              transmitter_power:  pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='moc']").text,
              name_type_station:  pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='parametry']").xpath("./*[local-name()='parametr']").xpath("./*[local-name()='przeznaczenie']").map(&:text).uniq.join(", "),
              emission:           pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='parametry']").xpath("./*[local-name()='parametr']").xpath("./*[local-name()='emisja']").map(&:text).uniq.join(", "),
              input_frequency:    pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='parametry']").xpath("./*[local-name()='parametr']").xpath("./*[local-name()='czestotliwoscOdb']").map(&:text).uniq.join(", "),
              output_frequency:   pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='parametry']").xpath("./*[local-name()='parametr']").xpath("./*[local-name()='czestotliwoscNad']").map(&:text).uniq.join(", "),
              station_location:   pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='adres']").xpath("./*[local-name()='miejscowosc']").text
            )

            puts 'id: '    + pozwol.xpath("./*[local-name()='id']").text
          else
            puts '******************** NIEAKTUALNE lub FIZYCZNY=false ********************'
            puts 'id: '    + pozwol.xpath("./*[local-name()='id']").text
            puts pozwol.xpath("./*[local-name()='sygnaturaEsod']").text.present? ? "#{pozwol.xpath("./*[local-name()='sygnaturaEsod']").text}" : "#{pozwol.xpath("./*[local-name()='numer']").text}"
          end
        end
      end
    end
  end  
end
