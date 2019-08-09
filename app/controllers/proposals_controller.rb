class ProposalsController < ApplicationController
  

  before_action :authenticate_user!
  before_action :set_proposal, only: [:show, :edit, :update, :destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /proposals
  # GET /proposals.json
  def index
    @proposals = policy_scope(Proposal)    
  end

  # GET /proposals/1
  # GET /proposals/1.json
  def show
    authorize @proposal, :show_self?
  end

  # GET /proposals/new
  def new
    @proposal = Proposal.new
    @proposal.creator = current_user
    authorize @proposal, :show_self?
  end

  # GET /proposals/1/edit
  def edit
  end

  # POST /proposals
  # POST /proposals.json
  def create
    @proposal = Proposal.new(proposal_params)
    authorize @proposal, :create_self?

    respond_to do |format|
      if @proposal.save
        format.html { redirect_to @proposal, notice: 'Proposal was successfully created.' }
        format.json { render :show, status: :created, location: @proposal }
      else
        format.html { render :new }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /proposals/1
  # PATCH/PUT /proposals/1.json
  def update
    respond_to do |format|
      if @proposal.update(proposal_params)
        format.html { redirect_to @proposal, notice: 'Proposal was successfully updated.' }
        format.json { render :show, status: :ok, location: @proposal }
      else
        format.html { render :edit }
        format.json { render json: @proposal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /proposals/1
  # DELETE /proposals/1.json
  def destroy
    # @proposal.destroy
    # respond_to do |format|
    #   format.html { redirect_to proposals_url, notice: 'Proposal was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
    authorize @proposal, :destroy_self?
    if @proposal.destroy
      #flash[:success].new = t('activerecord.successfull.messages.destroyed', data: '')
      flash[:success] = t('activerecord.successfull.messages.destroyed', data: rec_data_info(proposal)) 
      #@proposal.log_work('destroy', current_user.id)
      redirect_to proposals_url
    else 
      flash.now[:error] = t('activerecord.errors.messages.destroyed', data: rec_data_info(proposal))
      redirect_to proposals_url
    end      
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:status, :name, :given_names, :category, :creator_id)
    end
end

