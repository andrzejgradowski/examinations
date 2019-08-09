require 'csv'
require 'pit'

class Club < ApplicationRecord
  delegate :url_helpers, to: 'Rails.application.routes'

  before_validation :geocode_lat_lng 

  def geocode_lat_lng
    if (self.lat.nil? || self.lat == 0.0 || self.lng.nil? || self.lng == 0.0 )
      self.lat, self.lng = PitModule::Geocoder::localize_x_y("#{self.full_station_address}") unless self.full_station_address.blank?
    end
  end

  def number_as_link( loc )
    "<a href=#{url_helpers.club_path(self.id, locale: loc)}>#{self.number}</a>".html_safe
  end

  # for PitModule:Geokoder
  def full_station_address
    "#{self.station_city} #{self.station_street} #{self.station_house}"
  end

  # rubocop:disable MethodLength
  def self.to_csv
    CSV.generate(headers: false, col_sep: ';', converters: nil, skip_blanks: false, force_quotes: false) do |csv|
      columns_header = %w(number valid_to call_sign category transmitter_power applicant_name applicant_city applicant_street
                          applicant_house applicant_number enduser_name enduser_city enduser_street
                          enduser_house enduser_number station_city station_street station_house station_number lat lng)
      csv << columns_header
      all.each do |rec|
        csv << [rec.number.strip,
                rec.valid_to,
                rec.call_sign,
                rec.category,
                rec.transmitter_power,
                rec.applicant_name,
                rec.applicant_city,
                rec.applicant_street,
                rec.applicant_house,
                rec.applicant_number,
                rec.enduser_name,
                rec.enduser_city,
                rec.enduser_street,
                rec.enduser_house,
                rec.enduser_number,
                rec.station_city,
                rec.station_street,
                rec.station_house,
                rec.station_number,
                rec.lat,
                rec.lng]
      end
    end.encode('WINDOWS-1250')
  end

  def self.load_from_pwid(doc)
    #Club.destroy_all
    ActiveRecord::Base.connection.execute("TRUNCATE clubs RESTART IDENTITY")
    doc.xpath("//*[local-name()='wyszukajPozwoleniaKluboweResponse']").each do |resp|
      resp.xpath("./*[local-name()='return']").each do |ret|
        ret.xpath("./*[local-name()='pozwolenie']").each do |pozwol|

          if pozwol.xpath("./*[local-name()='status']").text == 'Aktualna'

            applicant_city = ''
            applicant_street = ''
            applicant_house = ''
            applicant_number = ''

            pozwol.xpath("./*[local-name()='wnioskodawca']").xpath("./*[local-name()='adresy']").xpath("./*[local-name()='adres']").each do |applicant_address|
              if applicant_address.xpath("./*[local-name()='rodzajAdresu']").text == 'siedziby'
                applicant_city    = applicant_address.xpath("./*[local-name()='miejscowosc']").text
                applicant_street  = applicant_address.xpath("./*[local-name()='ulica']").text 
                applicant_house   = applicant_address.xpath("./*[local-name()='nrDomu']").text
                applicant_number  = applicant_address.xpath("./*[local-name()='nrLokalu']").text
              end 
            end


            enduser_city = ''
            enduser_street = ''
            enduser_house = ''
            enduser_number = ''

            pozwol.xpath("./*[local-name()='uzytkownik']").xpath("./*[local-name()='adresy']").xpath("./*[local-name()='adres']").each do |enduser_address|
              if enduser_address.xpath("./*[local-name()='rodzajAdresu']").text == 'siedziby'
                enduser_city    = enduser_address.xpath("./*[local-name()='miejscowosc']").text
                enduser_street  = enduser_address.xpath("./*[local-name()='ulica']").text 
                enduser_house   = enduser_address.xpath("./*[local-name()='nrDomu']").text
                enduser_number  = enduser_address.xpath("./*[local-name()='nrLokalu']").text
              end 
            end

            club = Club.create(
              number:             pozwol.xpath("./*[local-name()='sygnaturaEsod']").text.present? ? pozwol.xpath("./*[local-name()='sygnaturaEsod']").text : pozwol.xpath("./*[local-name()='numer']").text,
              date_of_issue:      pozwol.xpath("./*[local-name()='waznaOd']").text,
              valid_to:           pozwol.xpath("./*[local-name()='waznaDo']").text,
              call_sign:          pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='znak']").text,
              category:           pozwol.xpath("./*[local-name()='wniosek']").xpath("./*[local-name()='kategoria']").text,
              transmitter_power:  pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='moc']").text,
              station_city:       pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='adres']").xpath("./*[local-name()='miejscowosc']").text,
              station_street:     pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='adres']").xpath("./*[local-name()='ulica']").text,
              station_house:      pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='adres']").xpath("./*[local-name()='nrDomu']").text,
              station_number:     pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='adres']").xpath("./*[local-name()='nrLokalu']").text,
              applicant_name:     pozwol.xpath("./*[local-name()='wnioskodawca']").xpath("./*[local-name()='nazwa']").text,
              applicant_city:     applicant_city,
              applicant_street:   applicant_street,
              applicant_house:    applicant_house,
              applicant_number:   applicant_number,
              enduser_name:       pozwol.xpath("./*[local-name()='uzytkownik']").xpath("./*[local-name()='nazwa']").text,
              enduser_city:       enduser_city,
              enduser_street:     enduser_street,
              enduser_house:      enduser_house,
              enduser_number:     enduser_number
            )

            puts 'id: '    + pozwol.xpath("./*[local-name()='id']").text + "   GEOCODER:   lat: #{club.lat} lng: #{club.lng}"
          else
            puts '******************** NIEAKTUALNE ********************'
            puts 'id: '    + pozwol.xpath("./*[local-name()='id']").text
            puts pozwol.xpath("./*[local-name()='sygnaturaEsod']").text.present? ? "#{pozwol.xpath("./*[local-name()='sygnaturaEsod']").text}" : "#{pozwol.xpath("./*[local-name()='numer']").text}"
          end
        end
      end
    end
  end  
end
