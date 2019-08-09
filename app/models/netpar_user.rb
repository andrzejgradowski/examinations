require 'net/http'

class NetparUser
	include ActiveModel::Model

	attr_accessor :name, :token, :authorization_str

  def initialize()
    super
    @authorization_str = "#{Rails.application.secrets[:netpar2015_api_basic_str]}"    
  end

  def request_for_token 
    begin 
      uri = URI.parse("#{Rails.application.secrets[:netpar2015_api_url]}/token")
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Basic #{self.authorization_str}"

      req_options = {
        # use_ssl: uri.scheme == "https",
        # verify_mode: OpenSSL::SSL::VERIFY_NONE
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      body_parsed = JSON.parse(response.body)
      self.token = body_parsed["token"]
    rescue => e
      Rails.logger.error('======================== API ERROR "/token" ================================')
      Rails.logger.error("#{e}")
      Rails.logger.error('=============================================================================')
    end
  end


end
