require "ruby-saml"

class Users::SamlSessionsController < Devise::SessionsController
  include DeviseSamlAuthenticatable::SamlConfig
  unloadable if Rails::VERSION::MAJOR < 4
  if Rails::VERSION::MAJOR < 5
    skip_before_filter :verify_authenticity_token
  else
    skip_before_action :verify_authenticity_token, raise: false
  end

  def new
    idp_entity_id = get_idp_entity_id(params)
    request = OneLogin::RubySaml::Authrequest.new
    auth_params = { RelayState: relay_state } if relay_state
    action = request.create(saml_config(idp_entity_id), auth_params || {})
    redirect_to action
  end

  # def create
  #   puts '----------------------------------------'
  #   puts 'SamlSessionsController "create"'
  #   puts '----------------------------------------'
  #   super
  # end


  # def create
  #   puts '----------------------------------------'
  #   puts 'SamlSessionsController "create"'
  #   puts '----------------------------------------'
  #   begin
  #     response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: saml_config)
  #     if response.is_valid?
  #       attribute_map = YAML.load(File.read("#{Rails.root}/config/attribute-map.yml"))
  #       attributes = Hash[response.attributes.map { |k, v| [attribute_map[k], v[0]] }]
  #       @user = User.load_saml_data attributes
  #       # session[:userid] = response.nameid
  #       # session[:attributes] = response.attributes
  #       # session[:userid] = @user.email
  #       session[:email] = @user.email
  #       if @user.persisted?
  #         flash[:notice] = 'Signed in successfully.'
  #         #sign_in_and_redirect @user #, :event => :authentication
  #         sign_in @user #, :event => :authentication
  #       end
  #     else
  #       raise 'Invalid response'
  #     end
  #   rescue Exception => e
  #     flash[:notice] = e.message
  #     redirect_to root_path
  #   end
  # end

  def after_sign_in_path_for(resource_or_scope)
    # BJ 2019.07.23
    #stored_location_for(resource_or_scope) || proposals_path(locale: locale)
    stored_location_for(resource_or_scope) || uke_regulations_path(locale: locale)
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(saml_config)
  end

  def idp_sign_out
    if params[:SAMLRequest] && Devise.saml_session_index_key
      saml_config = saml_config(get_idp_entity_id(params))
      logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest], settings: saml_config)
      resource_class.reset_session_key_for(logout_request.name_id)

      redirect_to generate_idp_logout_response(saml_config, logout_request.id)
    elsif params[:SAMLResponse]
      #Currently Devise handles the session invalidation when the request is made.
      #To support a true SP initiated logout response, the request ID would have to be tracked and session invalidated
      #based on that.
      if Devise.saml_sign_out_success_url
        redirect_to Devise.saml_sign_out_success_url
      else
        redirect_to action: :new
      end
    else
      head :invalid_request
    end
  end

  protected

  def relay_state
    @relay_state ||= if Devise.saml_relay_state.present?
      Devise.saml_relay_state.call(request)
    end
  end

  # Override devise to send user to IdP logout for SLO
  def after_sign_out_path_for(_)
    idp_entity_id = get_idp_entity_id(params)
    request = OneLogin::RubySaml::Logoutrequest.new
    request.create(saml_config(idp_entity_id))
  end

  def generate_idp_logout_response(saml_config, logout_request_id)
    OneLogin::RubySaml::SloLogoutresponse.new.create(saml_config, logout_request_id, nil)
  end
end