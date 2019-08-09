require 'digest'

module PwidModule

  # instancja testowa ESB
  # 10.40.2.4:8443 LB 
  # 10.40.2.5:8243(epl-tesb1) i 
  # 10.40.2.6:8243(epl-tesb2) 

  # instancja produkcyjna ESB
  # 10.40.1.4:443 LB 
  # 10.40.1.5:8243(epl-esb1) i 
  # 10.40.1.6:8243(epl-esb2) 

  #  API_SERVER = "https://10.40.1.4:443" # LB programowy PROD
  #  API_SERVER = "https://10.40.2.4:8443" # LB programowy ESB-TEST
  #  API_SERVER = "https://10.60.0.105:443" # LB sprzetowy ESB-TEST (uwaga! inny port)

  # pwidtest
  # API_PROTOCOL = "http"
  # API_SERVER = "10.100.2.65"
  # API_PWID_USER = "test.amat@uke.gov.pl"
  # API_PWID_USER_PASS = nil
  # API_PWID_USER_PASS_SHA1 = 'b61571869b0be588659a3a8ef02d2bacf6844017'

  # pwidprod
  # amator.api@uke.gov.pl
  # 1qazXSW@
  # ef0f8b6ffb699f90933a3321b00ff6769e018b94

  API_PROTOCOL = "https"
  API_SERVER = "10.100.2.64"
  API_PWID_USER = "amator.api@uke.gov.pl"
  API_PWID_USER_PASS = nil
  API_PWID_USER_PASS_SHA1 = 'ef0f8b6ffb699f90933a3321b00ff6769e018b94'


# for WSO2 Basic-Authorization
  API_SYSTEM_USER = "zz_Amator"
  API_SYSTEM_USER_PASS = "%gBcD32Sx"

  def self.pwid_user_sha1_pass
    if API_PWID_USER_PASS_SHA1.present? 
      API_PWID_USER_PASS_SHA1
    else
      Digest::SHA1.hexdigest "#{API_PWID_USER_PASS}"
    end
  end

  def self.pwid_whenever
    puts '----------------------------------------------------------------'
    puts 'RUN pwid_whenever...'
    start_run = Time.current
    load_individuals
    load_clubs
    load_devices
    puts "START: #{start_run}  END: #{Time.current}"
    puts '----------------------------------------------------------------'
  end

  def self.load_individuals
    xml_doc = %x{
      curl "#{API_PROTOCOL}://#{API_SERVER}/Pwid.Epl.Services.IIS.Host/PozwoleniePwidAmatorskieUsluga.svc/#{API_PROTOCOL}" \
        -X POST \
        -k \
        -H "Accept-Encoding: gzip,deflate" \
        -H "SOAPAction: \"http://pozwoleniePwidAmatorskie.dokument.uslugi.epl.uke.gov.pl/IPozwoleniePwidAmatorskieUsluga/wyszukajPozwoleniaIndywidualne\"" \
        -H "Connection: Keep-Alive" \
        -H "Content-Type: text/xml; charset=UTF-8" \
        -H "Cache-Control: no-cache" \
        -d "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:poz='http://pozwoleniePwidAmatorskie.dokument.uslugi.epl.uke.gov.pl/'>
              <soapenv:Header>
                <Security xmlns='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>
                  <wsse:UsernameToken wsu:Id='SecurityToken-24fe141f-9f4a-40d1-ac12-f31f39f85fc2' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>
                    <wsse:Username>"#{API_PWID_USER}"</wsse:Username>
                    <wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>"#{pwid_user_sha1_pass}"</wsse:Password>
                  </wsse:UsernameToken>
                </Security>
              </soapenv:Header>
                <soapenv:Body>
                  <poz:wyszukajPozwoleniaIndywidualne>
                    <parametryOperacjiWyszukajPozwoleniaIndywidualne>
                      <daneOsobowe>false</daneOsobowe>
                    </parametryOperacjiWyszukajPozwoleniaIndywidualne>
                  </poz:wyszukajPozwoleniaIndywidualne>
                </soapenv:Body>
            </soapenv:Envelope>" 
    }

    doc = Nokogiri::XML(xml_doc)
    #print doc
    Individual.load_from_pwid(doc)
  end

  def self.load_clubs
    xml_doc = %x{
      curl "#{API_PROTOCOL}://#{API_SERVER}/Pwid.Epl.Services.IIS.Host/PozwoleniePwidAmatorskieUsluga.svc/#{API_PROTOCOL}" \
        -X POST \
        -k \
        -H "Accept-Encoding: gzip,deflate" \
        -H "SOAPAction: \"http://pozwoleniePwidAmatorskie.dokument.uslugi.epl.uke.gov.pl/IPozwoleniePwidAmatorskieUsluga/wyszukajPozwoleniaKlubowe\"" \
        -H "Connection: Keep-Alive" \
        -H "Content-Type: text/xml; charset=UTF-8" \
        -H "Cache-Control: no-cache" \
        -d "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:poz='http://pozwoleniePwidAmatorskie.dokument.uslugi.epl.uke.gov.pl/'>
              <soapenv:Header>
                <Security xmlns='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>
                  <wsse:UsernameToken wsu:Id='SecurityToken-24fe141f-9f4a-40d1-ac12-f31f39f85fc2' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>
                    <wsse:Username>"#{API_PWID_USER}"</wsse:Username>
                    <wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>"#{pwid_user_sha1_pass}"</wsse:Password>
                  </wsse:UsernameToken>
                </Security>
              </soapenv:Header>
                <soapenv:Body>
                  <poz:wyszukajPozwoleniaKlubowe>
                    <parametryOperacjiWyszukajPozwoleniaKlubowe>
                      <daneOsobowe>true</daneOsobowe>
                    </parametryOperacjiWyszukajPozwoleniaKlubowe>
                  </poz:wyszukajPozwoleniaKlubowe>
                </soapenv:Body>
            </soapenv:Envelope>" 
    }

    doc = Nokogiri::XML(xml_doc)
    #print doc
    Club.load_from_pwid(doc)
  end

  def self.load_devices
    xml_doc = %x{
      curl "#{API_PROTOCOL}://#{API_SERVER}/Pwid.Epl.Services.IIS.Host/PozwoleniePwidAmatorskieUsluga.svc/#{API_PROTOCOL}" \
        -X POST \
        -k \
        -H "Accept-Encoding: gzip,deflate" \
        -H "SOAPAction: \"http://pozwoleniePwidAmatorskie.dokument.uslugi.epl.uke.gov.pl/IPozwoleniePwidAmatorskieUsluga/wyszukajPozwoleniaBezobslugowe\"" \
        -H "Connection: Keep-Alive" \
        -H "Content-Type: text/xml; charset=UTF-8" \
        -H "Cache-Control: no-cache" \
        -d "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/' xmlns:poz='http://pozwoleniePwidAmatorskie.dokument.uslugi.epl.uke.gov.pl/'>
              <soapenv:Header>
                <Security xmlns='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'>
                  <wsse:UsernameToken wsu:Id='SecurityToken-24fe141f-9f4a-40d1-ac12-f31f39f85fc2' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'>
                    <wsse:Username>"#{API_PWID_USER}"</wsse:Username>
                    <wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>"#{pwid_user_sha1_pass}"</wsse:Password>
                  </wsse:UsernameToken>
                </Security>
              </soapenv:Header>
                <soapenv:Body>
                  <poz:wyszukajPozwoleniaBezobslugowe>
                    <parametryOperacjiWyszukajPozwoleniaBezobslugowe>
                      <daneOsobowe>true</daneOsobowe>
                    </parametryOperacjiWyszukajPozwoleniaBezobslugowe>
                  </poz:wyszukajPozwoleniaBezobslugowe>
                </soapenv:Body>
            </soapenv:Envelope>" 
    }

    doc = Nokogiri::XML(xml_doc)
    #print doc
    IndividualDevice.load_from_pwid(doc)
    ClubDevice.load_from_pwid(doc)
  end
end
