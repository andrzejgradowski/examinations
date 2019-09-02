require 'net/http'

class NetparUser
  include ActiveModel::Model

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    Errno::ECONNREFUSED
  ]

  attr_accessor :username, :password, :token

  def initialize()
    @username = "#{Rails.application.secrets[:netpar2015_api_user]}"    
    @password = "#{Rails.application.secrets[:netpar2015_api_user_pass]}"    
  end

  def request_for_token 
    uri = URI.parse("#{Rails.application.secrets[:netpar2015_api_url]}/token")
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@username, @password)

    req_options = {
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    } if uri.scheme == "https"

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    body_parsed = JSON.parse(response.body)
    @token = body_parsed["token"]
    response

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/netpar_user/request_for_token (1) ================')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #response || false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/netpar_user/request_for_token (2)" ===============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false
    "#{e}"
  else
    case response
    when Net::HTTPOK
      #true   # success response
      response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('======== API ERROR "models/netpar_user/request_for_token (3)" ===============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      #false  # non-success response
      response
    end
  end


  def self.netparuser_token
    $user_netpar_token_last_used ||= nil 
    $user_netpar_token ||= nil

    if $user_netpar_token_last_used.blank? || (Time.zone.now - $user_netpar_token_last_used > 590.seconds)
      $user_netpar_token_last_used = Time.zone.now
      netpar_user_obj = NetparUser.new
      netpar_user_obj_response = netpar_user_obj.request_for_token 
      $user_netpar_token = netpar_user_obj.token || ''
    else
      $user_netpar_token_last_used = Time.zone.now
      $user_netpar_token 
    end
  end

end