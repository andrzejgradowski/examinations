class NetparController < ApplicationController

  def exam_show
    exam_obj = NetparExam.new(token: user_netpar_token, id: "#{params[:id]}")
    response_obj = exam_obj.request_with_id
    render json: response_obj.body, status: response_obj.code 
  end

  def exams_select2_index
    exams_obj = NetparExam.new(token: user_netpar_token, category: "#{params[:category]}", q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    response_obj = exams_obj.request_collection
    render json: response_obj.body, status: response_obj.code 
  end


  def division_show
    division_obj = NetparDivision.new(token: user_netpar_token, id: "#{params[:id]}")
    response_obj = division_obj.request_with_id
    render json: response_obj.body, status: response_obj.code 
  end

  def divisions_select2_index
    divisions_obj = NetparDivision.new(token: user_netpar_token, category: "#{params[:category]}", q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    response_obj = divisions_obj.request_collection
    render json: response_obj.body, status: response_obj.code 
  end

end
