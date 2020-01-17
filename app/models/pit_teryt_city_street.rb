# frozen_string_literal: true

require 'net/http'

class PitTerytCityStreet
  include ActiveModel::Model

  attr_accessor :response, :q, :array_streets, :array_query_streets, :city_id, :row_data, :id, :name

  def initialize(params = {})
    @city_id = params.fetch(:city_id, '0').to_i
    @id = params.fetch(:id, '0').to_i
    @q = params.fetch(:q, '')
  end

  def run_request
    uri = URI("#{Rails.application.secrets[:teryt_api_url]}/City/#{@city_id}/Streets")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    # /SSL
    @response = Net::HTTP.get_response(uri)

    @array_streets = JSON.parse(@response.body)
    # for init :id > 0 - show or index - collection
    if @id > 0
      streets = @array_streets.select{ |row| row['id'].to_s == "#{@id}" }.map{ |row| row }
      @row_data = streets[0]
      @id = @row_data['id']
      @name = @row_data['streetName']
    else 
      if @q.blank? # for index with query
        @array_query_streets = @array_streets
      else
        streets = @array_streets.select { |row| row['streetName'].downcase.include?(@q.downcase.to_s) }.map { |row| row }
        @array_query_streets = streets
      end
    end
    @response
  rescue StandardError => e
    puts '================= API ERROR "/City/:city_id/Streets" ========================'
    puts e.to_s
    puts '============================================================================='
  end
end
