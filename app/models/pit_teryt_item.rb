# frozen_string_literal: true

require 'net/http'

class PitTerytItem
  include ActiveModel::Model
  # include ERB::Util #for url_encode

  attr_accessor :response, :q, :page, :page_limit, :array_items, :row_data, :id

  def initialize(params = {})
    @id = params.fetch(:id, '0').to_i
    @q = params.fetch(:q, '')
    @page = params.fetch(:page, 0)
    @page_limit = params.fetch(:page_limit, 10)
  end

  # def run_request_for_collection
  #   uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Street/Filter?terytEntryFilterByQuery.query=#{url_encode(@q)}&terytEntryFilterByQuery.limit=#{@page_limit}&terytEntryFilterByQuery.offset=#{@page}")
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   # SSL
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
  #   # /SSL
  #   @response = Net::HTTP.get_response(uri)

  #   # @array_items = JSON.parse(@response.body)
  #   # @response
  # rescue StandardError => e
  #   puts '================ API ERROR "/Province/:province_id/Districts" ==============='
  #   puts e.to_s
  #   puts '============================================================================='
  # end

  def run_request_for_collection
    uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Street/Filter")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    # /SSL

    params = {:"terytEntryFilterByQuery.query" => "#{@q}", :"terytEntryFilterByQuery.offset" => "#{@page}", :"terytEntryFilterByQuery.limit" => "#{@page_limit}"}
    uri.query = URI.encode_www_form(params)

    @response = Net::HTTP.get_response(uri)
  rescue StandardError => e
    puts '================= API ERROR "/Streets" ======================================'
    puts e.to_s
    puts '============================================================================='
  end


  def run_request_for_one_row
    uri = URI("#{Rails.application.secrets[:teryt_api_url]}/Street/#{@id}")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    # /SSL
    @response = Net::HTTP.get_response(uri)
  rescue StandardError => e
    puts '================= API ERROR "/Street/:id ===================================='
    puts e.to_s
    puts '============================================================================='
  end


end
