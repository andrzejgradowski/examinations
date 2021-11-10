class Netpar::DivisionsController < ApplicationController

  def index
    divisions_obj = NetparDivision.new(category: "#{params[:category]}", q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    if divisions_obj.request_for_collection # return true
      render json: JSON.parse(divisions_obj.response.body), status: divisions_obj.response.code
    else
      if divisions_obj.response.present?
         render json: { error: divisions_obj.response.message }, status: divisions_obj.response.code 
      else 
         render json: { error: divisions_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    division_obj = NetparDivision.new(id: "#{params[:id]}")
    if division_obj.request_for_one_row
      render json: JSON.parse(division_obj.response.body), status: division_obj.response.code
    else
      if division_obj.response.present?
         render json: { error: division_obj.response.message }, status: division_obj.response.code 
      else 
         render json: { error: division_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

end
