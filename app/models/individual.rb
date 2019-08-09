require 'csv'
class Individual < ApplicationRecord
  delegate :url_helpers, to: 'Rails.application.routes'

  def number_as_link( loc )
    "<a href=#{url_helpers.individual_path(self.id, locale: loc)}>#{self.number}</a>".html_safe
  end

  # rubocop:disable MethodLength
  def self.to_csv
    CSV.generate(headers: false, col_sep: ';', converters: nil, skip_blanks: false, force_quotes: false) do |csv|
      columns_header = %w(number valid_to call_sign category transmitter_power station_location)
      csv << columns_header
      all.each do |rec|
        csv << [rec.number.strip,
                rec.valid_to,
                rec.call_sign,
                rec.category,
                rec.transmitter_power,
                rec.station_location]
     end
    end.encode('WINDOWS-1250')
  end

  # Status decyzji – kod ze słownika DecyzjaStatus:
  # WPrzygotowaniu
  # PrzekazanaDoPodpisu
  # OczekujacaNaDoreczenie
  # Aktualna
  # Archiwalna

  # Rodzaj decyzji – kod ze słownika DecyzjaRodzaj:
  # DecyzjaZmieniajaca
  # DecyzjaOdmowna
  # DecyzjaUchylajaca
  # DecyzjaCofajaca
  # StwierdzenieWygasniecia
  # DecyzjaOkolicznosciowa
  # DecyzjaKontestowa

  def self.load_from_pwid(doc)
    #Individual.destroy_all
    ActiveRecord::Base.connection.execute("TRUNCATE individuals RESTART IDENTITY")

    doc.xpath("//*[local-name()='wyszukajPozwoleniaIndywidualneResponse']").each do |resp|
      resp.xpath("./*[local-name()='return']").each do |ret|
        ret.xpath("./*[local-name()='pozwolenie']").each do |pozwol|
          if pozwol.xpath("./*[local-name()='status']").text == 'Aktualna'
            # puts pozwol.xpath("./*[local-name()='id']").text
            Individual.create(
              number:             pozwol.xpath("./*[local-name()='sygnaturaEsod']").text.present? ? pozwol.xpath("./*[local-name()='sygnaturaEsod']").text : pozwol.xpath("./*[local-name()='numer']").text,
              date_of_issue:      pozwol.xpath("./*[local-name()='waznaOd']").text,
              valid_to:           pozwol.xpath("./*[local-name()='waznaDo']").text,
              call_sign:          pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='znak']").text,
              category:           pozwol.xpath("./*[local-name()='wniosek']").xpath("./*[local-name()='kategoria']").text,
              transmitter_power:  pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='moc']").text,
              station_location:   pozwol.xpath("./*[local-name()='stacja']").xpath("./*[local-name()='adres']").xpath("./*[local-name()='miejscowosc']").text
            )

            puts 'id: '    + pozwol.xpath("./*[local-name()='id']").text
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
