class Netpar::ExamsController < ApplicationController

  def index
    params[:category] = category_params_validate(params[:category])
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

  def show
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

  private
    def category_params_validate(category_service)
      unless ['l', 'm', 'r', 'L', 'M', 'R', '', nil].include?(category_service)
        raise "Ruby injection"
      end
      return category_service.upcase
    end
end
