class UkeRegulationsController < ApplicationController

  before_action :authenticate_user!

  # GET /uke_regulations
  # GET /uke_regulations.json
  def index
    ur = UkeRegulation.new(user_name: current_user.email)
    ur.check_acceptance

    if ur.response.kind_of? Net::HTTPSuccess
      if ur.accepted
        #redirect_to proposals_path
        redirect_to root_path
      else
        sign_out if user_signed_in? 
        url = ur.generate_acceptance_url
        redirect_to "#{url}"
      end
    else
      sign_out if user_signed_in?     
      flash[:error] = "Errors:  #{ur.errors.full_messages}"
      redirect_to root_path
    end
    # flash[:warning] = "Odblokuj UkeRegulations"
    # redirect_to root_path
  end

end

