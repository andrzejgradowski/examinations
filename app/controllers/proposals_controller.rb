class ProposalsController < ApplicationController
  include ProposalsHelper
  
  before_action :authenticate_user!
  before_action :set_proposal, only: [:show, :update_annulled]

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

  # GET /proposals/new
  def new
    if params[:wizard_step].blank?
      session[:proposal_params] ||= ActionController::Parameters.new
      @proposal = Proposal.new 
      @proposal.current_step = session[:proposal_step]
    else
      session[:proposal_params] = ActionController::Parameters.new
      @proposal = Proposal.new 
      clear_attached_to_user_files
      @proposal.current_step = session[:proposal_step] = params[:wizard_step]
    end 

    set_init_user_profile_attributes
    authorize @proposal, :new_self?
  end

  def create
    puts '------------------------------------------------------'
    puts 'ProposalsController -> create'
    puts params
    puts '------------------------------------------------------'
    @proposal = Proposal.new
    set_init_user_profile_attributes
    @proposal.esod_category = 41

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

  private

    def set_init_user_profile_attributes
      @proposal.creator_id  = current_user.id
      @proposal.email       = current_user.email
      @proposal.name        = current_user.last_name
      @proposal.given_names = current_user.first_name
      @proposal.pesel       = current_user.pesel
      @proposal.birth_date  = current_user.birth_date
      @proposal.birth_place = current_user.birth_city
      @proposal.family_name = current_user.family_name
      @proposal.phone       = current_user.phone
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_proposal
      @proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
      # @proposal = Proposal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:creator_id,
        :email, :phone, :name, :given_names, :pesel, :citizenship_code, :birth_date, :birth_place, :family_name, 
        :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
        :category, :esod_category, :exam_id, :exam_fullname, :exam_date_exam, 
        :division_id, :division_fullname, :division_short_name, :division_min_years_old, 
        :exam_fee_id, :exam_fee_price, :bank_pdf, :face_image, :consent_pdf)
    end

end

