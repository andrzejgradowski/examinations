require 'net/http'

class NetparExamFee
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

  attr_accessor :response, :id, :division_id, :esod_category

  def initialize(params = {})
    @id = params.fetch(:id, 0)
    @division_id = params.fetch(:division_id, 0)
    @esod_category = params.fetch(:esod_category, 0)
  end

  def request_with_id
    uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/exam_fees/#{@id}")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 
    req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{NetparUser.netparuser_token}"})
    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/netpar_exam_fee/request_with_id" (1) =============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/netpar_exam_fee/request_with_id" (2) =============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  else
    case response
    when Net::HTTPOK
      #true   # success response
      response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('======== API ERROR "models/netpar_exam_fee/request_with_id" (3) =============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      #false  # non-success response
      response
    end
  end

  def request_find
    uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/exam_fees/find")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 
    req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{NetparUser.netparuser_token}"})
    params = {:division_id => "#{@division_id}", :esod_category => "#{@esod_category}"}
    req.body = params.to_json
    @response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/netpar_exam_fee/find" (1) ========================')
    Rails.logger.error("#{e}")
    Rails.logger.error('=============================================================================')
    errors.add(:base, "API ERROR 'models/netpar_exam_fee .request_find(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #{}"#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/netpar_exam_fee/find" (2) ========================')
    Rails.logger.error("#{e}")
    Rails.logger.error('=============================================================================')
    errors.add(:base, "API ERROR 'models/netpar_exam_fee .request_find(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #{}"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('======== API ERROR "models/netpar_exam_fee/find" (3) ========================')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      errors.add(:base, "API ERROR 'models/netpar_exam_fee .request_find(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end


end
