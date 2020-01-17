# frozen_string_literal: true

require 'net/http'

class PitTerytCommuneCity
  include ActiveModel::Model

  attr_accessor :response, :q, :array_cities, :array_query_cities, :commune_id, :row_data, :id, :name

  def initialize(params = {})
    @commune_id = params.fetch(:commune_id, '0').to_i
    @id = params.fetch(:id, '0').to_i
    @q = params.fetch(:q, '')
  end

  def run_request
    uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Commune/#{@commune_id}/Cities")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    # /SSL
    @response = Net::HTTP.get_response(uri)

    @array_cities = JSON.parse(@response.body)
    # for init :id > 0 - show or index - collection
    if @id > 0
      cities = @array_cities.select{ |row| row['id'].to_s == "#{@id}" }.map{ |row| row }
      @row_data = cities[0]
      @id = @row_data['id']
      @name = @row_data['name']
    else 
      if @q.blank? # for index with query
        @array_query_cities = @array_cities
      else
        cities = @array_cities.select { |row| row['name'].downcase.include?(@q.downcase.to_s) }.map { |row| row }
        @array_query_cities = cities
      end
    end
    @response
  rescue StandardError => e
    puts '================= API ERROR "/Commune/:commune_id/Cities" ==================='
    puts e.to_s
    puts '============================================================================='
  end
end
