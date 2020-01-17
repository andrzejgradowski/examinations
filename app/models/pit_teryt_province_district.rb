# frozen_string_literal: true

require 'net/http'

class PitTerytProvinceDistrict
  include ActiveModel::Model

  attr_accessor :response, :q, :array_districts, :array_query_districts, :province_id, :row_data, :id, :name

  def initialize(params = {})
    @province_id = params.fetch(:province_id, '0').to_i
    @id = params.fetch(:id, '0').to_i
    @q = params.fetch(:q, '')
  end

  def run_request
    uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Province/#{@province_id}/Districts")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    # /SSL
    @response = Net::HTTP.get_response(uri)

    @array_districts = JSON.parse(@response.body)
    # for init :id > 0 - show or index - collection
    if @id > 0
      districts = @array_districts.select{ |row| row['id'].to_s == "#{@id}" }.map{ |row| row }
      @row_data = districts[0]
      @id = @row_data['id']
      @name = @row_data['name']
    else 
      if @q.blank? # for index with query
        @array_query_districts = @array_districts
      else
        districts = @array_districts.select { |row| row['name'].downcase.include?(@q.downcase.to_s) }.map { |row| row }
        @array_query_districts = districts
      end
    end
    @response
  rescue StandardError => e
    puts '================ API ERROR "/Province/:province_id/Districts" ==============='
    puts e.to_s
    puts '============================================================================='
  end
end
