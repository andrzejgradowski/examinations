class ProposalsController < ApplicationController
  include ProposalsHelper
  
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

  # GET /proposals/1/edit
  def edit
    authorize @proposal, :edit_self?
  end

  # PATCH/PUT /proposals/1
  # PATCH/PUT /proposals/1.json
  def update
    authorize @proposal, :update_self?
    respond_to do |format|
      if @proposal.update(proposal_params)
        format.html { redirect_to proposals_url, notice: 'Proposal was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /proposals/1
  # DELETE /proposals/1.json
  def destroy
    authorize @proposal, :destroy_self?
    if @proposal.destroy
      flash[:success] = t('activerecord.successfull.messages.destroyed', data: proposal_rec_info(@proposal)) 
      redirect_to proposals_url
    else 
      #flash.now[:error] = t('activerecord.errors.messages.destroyed', data: proposal_rec_info(@proposal))

      @proposal.errors.full_messages.each do |msg|
        flash[:error] = msg
      end

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
      params.require(:proposal).permit(:proposal_status_id, :name, :given_names, :category)
    end
end

