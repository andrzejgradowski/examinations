class ApiTerytController < ApplicationController

  def items
    items_obj = ApiTerytAddress.new(q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    if items_obj.request_for_collection # return true
      render json: JSON.parse(items_obj.response.body), status: items_obj.response.code
    else
      if items_obj.response.present?
         render json: { error: items_obj.response.message }, status: items_obj.response.code 
      else 
         render json: { error: items_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def item_show
    item_obj = ApiTerytAddress.new(combine_id: params[:id])
    if item_obj.request_for_one_row
      render json: JSON.parse(item_obj.response.body), status: item_obj.response.code
    else
      if item_obj.response.present?
         render json: { error: item_obj.response.message }, status: item_obj.response.code 
      else 
         render json: { error: item_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

end
