class IndividualsController < ApplicationController
  before_action :authenticate_user!

  #caches_page :index, :gzip => :best_speed

  def export
    @data = Individual.all
    respond_to do |format|
      format.csv { send_data @data.to_csv, filename: "individuals_#{Time.zone.today.strftime("%Y-%m-%d")}.csv" }
    end
  end

  # GET /individuals
  # GET /individuals.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: IndividualDatatable.new(params) }
    end
  end

  # GET /individuals/1
  # GET /individuals/1.json
  def show
    @individual = Individual.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

end
