class ProposalsController < ApplicationController
  include ProposalsHelper
  
  before_action :authenticate_user!
  before_action :set_proposal, only: [:show, :update_annulled, :destroy]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  respond_to :html

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

  def create
    create_new_and_set_user_profile_attributes

    authorize @proposal, :create_self?
    @proposal.save(validate: false)

    redirect_to proposal_wizard_path(proposal_multi_app_identifier: @proposal.multi_app_identifier, id: Proposal.form_steps.first)  
  end

  def update_annulled
    authorize @proposal, :annulled_self?
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_ANNULLED

    if @proposal.save_rec_and_push('update')
      flash[:warning] = t('activerecord.successfull.messages.annulled', data: proposal_rec_info(@proposal))
      redirect_to proposal_url
    else
      @proposal.proposal_status_id_was
      render :show
    end
  end

  def destroy
    authorize @proposal, :destroy_self?
    @proposal.destroy()
    respond_to do |format|
      format.html { redirect_to proposals_url }
    end
  end

  private

    def create_new_and_set_user_profile_attributes
      @proposal = Proposal.new.tap do |pro|
        pro.esod_category = 41
        pro.creator_id    = current_user.id
        pro.email         = current_user.email
        pro.name          = current_user.last_name
        pro.given_names   = current_user.first_name
        pro.pesel         = current_user.pesel
        pro.birth_date    = current_user.birth_date
        pro.birth_place   = current_user.birth_city
        pro.family_name   = current_user.family_name
        pro.phone         = current_user.phone
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_proposal
      @proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
      # @proposal = Proposal.find(params[:id])
    end

end

