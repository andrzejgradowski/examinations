require 'net/http'

class NetparGradeWithResult
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

  attr_accessor :response, :multi_app_identifier

  def initialize(params = {})
    @multi_app_identifier = params.fetch(:multi_app_identifier, "")
  end

  def request_for_collection
    uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/proposals/#{@multi_app_identifier}/grades_with_result")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 
    req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{NetparUser.netparuser_token}"})

    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('===== API ERROR "models/netpar_negative_grade .request_for_collection"(1) ===')
    Rails.logger.error("#{e}")
    Rails.logger.error('=============================================================================')
    errors.add(:base, "API ERROR 'models/netpar_negative_grade .request_for_collection(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('===== API ERROR "models/netpar_negative_grade .request_for_collection"(2) ===')
    Rails.logger.error("#{e}")
    Rails.logger.error('=============================================================================')
    errors.add(:base, "API ERROR 'models/netpar_negative_grade .request_for_collection(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('===== API ERROR "models/netpar_negative_grade .request_for_collection"(3) ===')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      errors.add(:base, "API ERROR 'models/netpar_negative_grade .request_for_collection(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end


end