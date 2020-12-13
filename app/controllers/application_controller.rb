class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, except: :create

  before_action :set_locale
  
  before_action :check_browser, if: :html_request?

  def default_url_options
    { locale: I18n.locale }
  end

  private

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end

    def html_request?
      request.format.html?
    end

    def action_is_static_pages_home_alert?
      params[:controller] == 'static_pages' && params[:action] == 'home_alert'
    end

    def check_browser
      if browser.ie?
        redirect_to static_pages_home_alert_path
      end unless action_is_static_pages_home_alert?
    end

end
