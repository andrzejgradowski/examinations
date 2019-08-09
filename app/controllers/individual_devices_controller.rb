class IndividualDevicesController < ApplicationController

  #caches_page :index, :gzip => :best_speed

  def export
    @data = IndividualDevice.all
    respond_to do |format|
      format.csv { send_data @data.to_csv, filename: "individual_devices_#{Time.zone.today.strftime('%Y-%m-%d')}.csv" }
    end
  end

  # GET /individual_devices
  # GET /individual_devices.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: IndividualDeviceDatatable.new(params) }
    end
  end

  # GET /individual_devices/1
  # GET /individual_devices/1.json
  def show
    @individual_device = IndividualDevice.find(params[:id])
    respond_to do |format|
      format.html 
    end
  end

end
