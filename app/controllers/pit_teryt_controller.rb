class PitTerytController < ApplicationController

  def provinces
    provinces_obj = PitTerytProvince.new(q: params[:q])
    provinces_obj.run_request

    array_list = params[:q].blank? ? provinces_obj.array_provinces : provinces_obj.array_query_provinces
    render json: { provinces: array_list, meta: { total_count: array_list.size } }, status: provinces_obj.response.code
  end

  def province_show
    provinces_obj = PitTerytProvince.new(id: params[:id])
    provinces_obj.run_request

    render json: provinces_obj.row_data, status: provinces_obj.response.code
  end


  def province_districts
    districts_obj = PitTerytProvinceDistrict.new(province_id: params[:province_id], q: params[:q])
    districts_obj.run_request

    array_list = params[:q].blank? ? districts_obj.array_districts : districts_obj.array_query_districts
    array_list_on_page = Kaminari.paginate_array(array_list).page(params[:page]).per(params[:page_limit])

    render json: { districts: array_list_on_page, meta: { total_count: array_list.size } }, status: districts_obj.response.code
  end

  def province_district_show
    districts_obj = PitTerytProvinceDistrict.new(province_id: params[:province_id], id: params[:id])
    districts_obj.run_request

    render json: districts_obj.row_data, status: districts_obj.response.code
  end


  def district_communes
    communes_obj = PitTerytDistrictCommune.new(district_id: params[:district_id], q: params[:q])
    communes_obj.run_request

    array_list = params[:q].blank? ? communes_obj.array_communes : communes_obj.array_query_communes
    array_list_on_page = Kaminari.paginate_array(array_list).page(params[:page]).per(params[:page_limit])

    render json: { communes: array_list_on_page, meta: { total_count: array_list.size } }, status: communes_obj.response.code
  end

  def district_commune_show
    communes_obj = PitTerytDistrictCommune.new(district_id: params[:district_id], id: params[:id])
    communes_obj.run_request

    render json: communes_obj.row_data, status: communes_obj.response.code
  end


  def commune_cities
    cities_obj = PitTerytCommuneCity.new(commune_id: params[:commune_id], q: params[:q])
    cities_obj.run_request

    array_list = params[:q].blank? ? cities_obj.array_cities : cities_obj.array_query_cities
    array_list_on_page = Kaminari.paginate_array(array_list).page(params[:page]).per(params[:page_limit])

    render json: { cities: array_list_on_page, meta: { total_count: array_list.size } }, status: cities_obj.response.code
  end

  def commune_city_show
    cities_obj = PitTerytCommuneCity.new(commune_id: params[:commune_id], id: params[:id])
    cities_obj.run_request

    render json: cities_obj.row_data, status: cities_obj.response.code
  end


  def city_streets
    streets_obj = PitTerytCityStreet.new(city_id: params[:city_id], q: params[:q])
    streets_obj.run_request

    array_list = params[:q].blank? ? streets_obj.array_streets : streets_obj.array_query_streets
    array_list_on_page = Kaminari.paginate_array(array_list).page(params[:page]).per(params[:page_limit])

    render json: { streets: array_list_on_page, meta: { total_count: array_list.size } }, status: streets_obj.response.code
  end

  def city_street_show
    streets_obj = PitTerytCityStreet.new(city_id: params[:city_id], id: params[:id])
    streets_obj.run_request

    render json: streets_obj.row_data, status: streets_obj.response.code
  end


  def items
    items_obj = PitTerytItem.new(q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    items_obj.run_request_for_collection
    render json: JSON.parse(items_obj.response.body), status: items_obj.response.code
  end

  def item_show
    item_obj = PitTerytItem.new(id: params[:id])
    item_obj.run_request_for_one_row

    render json: JSON.parse(item_obj.response.body), status: item_obj.response.code
  end

end
