class NetparController < ApplicationController

  def division_show
    division_obj = NetparDivision.new(id: "#{params[:id]}")
    response_obj = division_obj.request_with_id
    render json: response_obj.body, status: response_obj.code 
  end

  def divisions_select2_index
    divisions_obj = NetparDivision.new(category: "#{params[:category]}", q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    response_obj = divisions_obj.request_collection
    render json: response_obj.body, status: response_obj.code 
  end

  def exam_show
    exam_obj = NetparExam.new(id: "#{params[:id]}")
    response_obj = exam_obj.request_with_id
    render json: response_obj.body, status: response_obj.code 
  end

  def exams_select2_index
    exams_obj = NetparExam.new(category: "#{params[:category]}", division_id: "#{params[:division_id]}", q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    response_obj = exams_obj.request_collection
    render json: response_obj.body, status: response_obj.code 
  end

end
