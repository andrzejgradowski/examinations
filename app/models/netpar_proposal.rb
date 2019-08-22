require 'net/http'

class NetparProposal
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

  attr_accessor :netpar_proposal, :multi_app_identifier

  delegate *::Proposal.attribute_names.map { |attr| [attr, "#{attr}="] }.flatten, to: :netpar_proposal


  def initialize(params = {})
    @multi_app_identifier = params.fetch(:multi_app_identifier, 0)
    # params netpar_proposal as Hash!
    @netpar_proposal = params.fetch("netpar_proposal".to_sym)
  end

  # def initialize(attributes)
  #   attributes.each do |attribute_name, attribute_value|
  #     ##### Method one #####
  #     # Works just great, but uses something scary like eval
  #     # self.class.class_eval {attr_accessor attribute_name}
  #     # self.instance_variable_set("@#{attribute_name}", attribute_value)

  #     ##### Method two #####
  #     # Manually creates methods for both getter and setter and then 
  #     # sends a message to the new setter with the attribute_value
  #     self.class.send(:define_method, "#{attribute_name}=".to_sym) do |value|
  #       instance_variable_set("@" + attribute_name.to_s, value)
  #     end

  #     self.class.send(:define_method, attribute_name.to_sym) do
  #       instance_variable_get("@" + attribute_name.to_s)
  #     end

  #     self.send("#{attribute_name}=".to_sym, attribute_value)
  #   end
  # end

  def request_create
    uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/proposals")
    # http = Net::HTTP.new(uri.host, uri.port)
    # # SSL 
    # http.use_ssl = true if uri.scheme == "https" 
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Token token=#{NetparUser.netparuser_token}"

    proposal_rec = @netpar_proposal
    proposal_data = Hash.new
    proposal_data['proposal'] = proposal_rec.compact

    request.set_form_data( proposal_data )
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.use_ssl = true if uri.scheme == "https" 
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
      http.request(request)
    end

    return response

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/netpar_proposal/request_create" (1) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/netpar_proposal/request_create" (2) ==============')
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
      Rails.logger.error('======== API ERROR "models/netpar_proposal/request_create" (3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      #false  # non-success response
      response
    end
  end

  def request_update
    uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/proposals/#{@multi_app_identifier}")
    # http = Net::HTTP.new(uri.host, uri.port)
    # # SSL 
    # http.use_ssl = true if uri.scheme == "https" 
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # # /SSL 

    request = Net::HTTP::Patch.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Token token=#{NetparUser.netparuser_token}"

    proposal_rec = @netpar_proposal
    proposal_data = Hash.new
    proposal_data['proposal'] = proposal_rec.compact

    request.set_form_data( proposal_data )
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.use_ssl = true if uri.scheme == "https" 
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
      http.request(request)
    end

    return response

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/netpar_proposal/request_update" (1) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/netpar_proposal/request_update" (2) ==============')
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
      Rails.logger.error('======== API ERROR "models/netpar_proposal/request_update" (3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      #false  # non-success response
      response
    end
  end


  def request_destroy
    uri = URI("#{Rails.application.secrets[:netpar2015_api_url]}/proposals/#{@multi_app_identifier}")
    http = Net::HTTP.new(uri.host, uri.port)
    # SSL 
    http.use_ssl = true if uri.scheme == "https" 
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == "https" # Sets the HTTPS verify mode
    # /SSL 
    req = Net::HTTP::Delete.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => "Token token=#{NetparUser.netparuser_token}"})
    response = http.request(req)

  rescue *HTTP_ERRORS => e
    Rails.logger.error('======== API ERROR "models/netpar_proposal/request_destroy" (1) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  rescue StandardError => e
    Rails.logger.error('======== API ERROR "models/netpar_proposal/request_destroy" (2) ==============')
    Rails.logger.error("#{e}")
    errors.add(:base, "#{e}")
    Rails.logger.error('=============================================================================')
    #false    # non-success response
    "#{e}"
  else
    case response
    when Net::HTTPNoContent
      #true   # success response
      response
    when Net::HTTPClientError, Net::HTTPInternalServerError
      Rails.logger.error('======== API ERROR "models/netpar_proposal/request_destroy" (3) ==============')
      Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
      errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
      Rails.logger.error('=============================================================================')
      #false  # non-success response
      response
    end
  end


end
