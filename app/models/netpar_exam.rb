require 'net/http'

class NetparExam
	include ActiveModel::Model

	attr_accessor :token, :category, :q, :page, :page_limit, :id

  def initialize(params = {})
    super
    @token = params.fetch(:token, '')
    @category = params.fetch(:category, '')
    @q = params.fetch(:q, '')
    @page = params.fetch(:page, 0)
    @page_limit = params.fetch(:page_limit, 0)
    @id = params.fetch(:id, 0)
  end

  def request_with_id
    begin
      uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/exams/#{self.id}")
      http = Net::HTTP.new(uri.host, uri.port)
      # SSL 
#      http.use_ssl = true
#      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      # /SSL 
      req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{self.token}"})
      #params = {:q => "#{self.q}"}
      #req.body = params.to_json
      response = http.request(req)
      #JSON.parse(response.body)
    rescue => e
      Rails.logger.error('======================== API ERROR "/exams/" ================================')
      Rails.logger.error("#{e}")
      Rails.logger.error('=============================================================================')
    end
  end

  def request_collection
    begin
      case self.category
      when 'R'
        uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/exams/ra_next_and_free")
      when 'M'
        uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/exams/mor_next_and_free")
      end

      http = Net::HTTP.new(uri.host, uri.port)
      # SSL 
#      http.use_ssl = true
#      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      # /SSL 
      req = Net::HTTP::Get.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{self.token}"})
      params = {:q => "#{self.q}", :page => "#{self.page}", :page_limit => "#{self.page_limit}"}
      req.body = params.to_json
      response = http.request(req)
      #JSON.parse(response.body)

    rescue => e
      Rails.logger.error('======================== API ERROR "/exams/" ================================')
      Rails.logger.error("#{e}")
      Rails.logger.error('=============================================================================')
    end
  end

end
