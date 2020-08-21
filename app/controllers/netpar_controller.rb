class NetparController < ApplicationController


  def divisions
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

  def division_show
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


  def exams
    exams_obj = NetparExam.new(category: "#{params[:category]}", division_id: "#{params[:division_id]}", q: "#{params[:q]}", page: "#{params[:page]}", page_limit: "#{params[:page_limit]}")
    if exams_obj.request_for_collection # return true
      render json: JSON.parse(exams_obj.response.body), status: exams_obj.response.code
    else
      if exams_obj.response.present?
         render json: { error: exams_obj.response.message }, status: exams_obj.response.code 
      else 
         render json: { error: exams_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def exam_show
    exam_obj = NetparExam.new(id: "#{params[:id]}")
    if exam_obj.request_for_one_row
      render json: JSON.parse(exam_obj.response.body), status: exam_obj.response.code
    else
      if exam_obj.response.present?
         render json: { error: exam_obj.response.message }, status: exam_obj.response.code 
      else 
         render json: { error: exam_obj.errors.messages }, status: :unprocessable_entity
      end
    end
  end

end
