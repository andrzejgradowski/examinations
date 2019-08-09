class ClubsController < ApplicationController

  #caches_page :index, :gzip => :best_speed

  def export
    @data = Club.all
    respond_to do |format|
      format.csv { send_data @data.to_csv, filename: "clubs_#{Time.zone.today.strftime("%Y-%m-%d")}.csv" }
    end
  end

  # GET /clubs
  # GET /clubs.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: ClubDatatable.new(params) }
    end
  end

  # GET /clubs/1
  # GET /clubs/1.json
  def show
    @club = Club.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

end
