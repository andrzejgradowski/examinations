require 'net/http'

module PitModule

  # API_URL = "http://testpit2map.uke.gov.pl/geokoder"
  # API_URL = "http://10.40.6.10(1)/geokoder" In F5 address -> cluster to 10.40.6.10 i 10.40.6.11
  API_URL = Rails.application.secrets.geokoder_api_url

  class Geocoder
    include ActiveModel::Model

    attr_accessor :localization, :lat, :lng

    def initialize(localization)
      @localization = "#{localization}".delete "," 
    end

    def get_localize
      begin
        #http://testpit2map.uke.gov.pl/geokoder?adres=W%C4%85chock%20dolna%201&epsg=4326
        uri = URI("#{API_URL}")
        query_params = { "adres" => "#{self.localization}", "epsg" => "4326" }
        uri.query = URI.encode_www_form(query_params)
        # SSL 
        #http = Net::HTTP.new(uri.host, uri.port)
        #http.use_ssl = true
        #http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
        # /.SSL 
        response = Net::HTTP.get_response(uri)

        # {"adresy":
        #   [{"X":"289607.654028","Y":"445515.822221","gmina":"Le\u015bnica","miejscowosc":"Dolna","numerporzadkowy":null,"powiat":"strzelecki","ulica":null,"wojewodztwo":"opolskie"},
        #    {"X":"358117.5106","Y":"640701.41","gmina":"W\u0105chock","miejscowosc":"W\u0105chock","numerporzadkowy":"1","powiat":"starachowicki","ulica":"Dolna","wojewodztwo":"\u015bwi\u0119tokrzyskie"},
        #    {"X":"358107.3609","Y":"640690.76","gmina":"W\u0105chock","miejscowosc":"W\u0105chock","numerporzadkowy":"1A","powiat":"starachowicki","ulica":"Dolna","wojewodztwo":"\u015bwi\u0119tokrzyskie"}
        #  ],
        # "control":"1548225283095"}


        if response.is_a?(Net::HTTPSuccess)
          res = JSON.parse(response.body) 

          self.lng = res['adresy'][0]['X']
          self.lat = res['adresy'][0]['Y']
        #   render json: response.body, status: response.code
        # else
        #   render json: { "error" => "API #{API_URL}", "code" => "#{response.code}"}, status: response.code
        end
        response.body
      rescue => e
        puts "================================= API ERROR ================================="
        puts "#{uri}"
        puts "#{e}"
        puts '============================================================================='
      end
    end

    def self.localize_x_y(address)
      g = Geocoder.new(address)
      g.get_localize
      return g.lat, g.lng
    end

  end
end
