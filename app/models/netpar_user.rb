require 'net/http'

class NetparUser
	include ActiveModel::Model

	attr_accessor :username, :password, :token

  def initialize()
    super
    @username = "#{Rails.application.secrets[:netpar2015_api_user]}"    
    @password = "#{Rails.application.secrets[:netpar2015_api_user_pass]}"    
  end

  def request_for_token 
    begin 
      uri = URI.parse("#{Rails.application.secrets[:netpar2015_api_url]}/token")
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(self.username, self.password)

      req_options = {
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      } if uri.scheme == "https"

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
