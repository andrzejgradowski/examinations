class PitTerytController < ApplicationController

  def items
    items_obj = PitTerytItem.new(q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    items_obj.request_for_collection
    render json: JSON.parse(items_obj.response.body), status: items_obj.response.code
  end

  def item_show
    item_obj = PitTerytItem.new(id: params[:id])
    item_obj.request_for_one_row

    render json: JSON.parse(item_obj.response.body), status: item_obj.response.code
  end

end
