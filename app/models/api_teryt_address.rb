require 'net/http'

class ApiTerytAddress
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

  attr_accessor :response, :q, :page, :page_limit, :combine_id

  def initialize(params = {})
    @combine_id = params.fetch(:combine_id, '')
    @q = params.fetch(:q, '')
    @page = params.fetch(:page, 1)
    @page_limit = params.fetch(:page_limit, 100)
  end

  def request_for_collection
    uri = URI("#{Rails.application.secrets[:api_teryt_url]}/Address")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true if uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL
    params = {:"Query" => "#{@q}", :"Offset" => "#{@page}", :"Limit" => "#{@page_limit}", :"Order" => "name", :"OrderDir" => "asc"}
    uri.query = URI.encode_www_form(params)

    @response = Net::HTTP.get_response(uri)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_teryt_address .request_for_collection"(1) =============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_teryt_address .request_for_collection(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_teryt_address .request_for_collection"(2) =============')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_teryt_address .request_for_collection(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_teryt_address .request_for_collection"(3) =============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_teryt_address .request_for_collection(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end


  def request_for_one_row
    uri = URI("#{Rails.application.secrets[:api_teryt_url]}/Address/#{@combine_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true if uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL
    @response = Net::HTTP.get_response(uri)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('== API ERROR "models/api_teryt_address .request_for_one_row"(1) ================')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_teryt_address .request_for_one_row'(1) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  rescue StandardError => e
    Rails.logger.error('== API ERROR "models/api_teryt_address .request_for_one_row"(2) ================')
    Rails.logger.error("#{e}")
    Rails.logger.error('================================================================================')
    errors.add(:base, "API ERROR 'models/api_teryt_address .request_for_one_row'(2) #{Time.zone.now}")
    errors.add(:base, "#{e}")
    false    # non-success response
    #"#{e}"
  else
    case response
    when Net::HTTPOK
      true   # success response
      #response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('== API ERROR "models/api_teryt_address .request_for_one_row"(3) ================')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('================================================================================')
      errors.add(:base, "API ERROR 'models/api_teryt_address .request_for_one_row'(3) #{Time.zone.now}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      false  # non-success response
      #response
    end
  end

end