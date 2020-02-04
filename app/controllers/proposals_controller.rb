class ProposalsController < ApplicationController
  include ProposalsHelper
  
  before_action :authenticate_user!
  before_action :set_proposal, only: [:show, :update_annulled, :create_correction_exam, :destroy]

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

  def create_correction_exam
    authorize @proposal, :create_correction_exam_self?

    create_correction_exam_and_set_user_profile_attributes_and_old_proposal_attributes

    @proposal_correction_exam.save(validate: false)

    redirect_to proposal_wizard_path(proposal_multi_app_identifier: @proposal_correction_exam.multi_app_identifier, id: Proposal.form_steps.first)  
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


    def decode_birth_date_from_pesel(nr_pesel)
      unless Activepesel::Pesel.new(nr_pesel).valid?
        nil
      else
        Activepesel::Pesel.new(nr_pesel).date_of_birth
      end
    end

    def create_new_and_set_user_profile_attributes
      @proposal = Proposal.new.tap do |rec|
        rec.esod_category = Proposal::ESOD_CATEGORY_EGZAMIN
        rec.creator_id    = current_user.id
        rec.email         = current_user.email
        rec.name          = current_user.last_name
        rec.given_names   = current_user.first_name
        rec.pesel         = current_user.pesel
        rec.birth_date    = current_user.birth_date.present? ? current_user.birth_date : decode_birth_date_from_pesel(current_user.pesel)
        rec.birth_place   = current_user.birth_city
        rec.family_name   = current_user.family_name
        rec.phone         = current_user.phone
      end
    end


    def create_correction_exam_and_set_user_profile_attributes_and_old_proposal_attributes
      @proposal_correction_exam = Proposal.new.tap do |rec|
        rec.esod_category = Proposal::ESOD_CATEGORY_POPRAWKOWY
        rec.creator_id    = current_user.id
        rec.email         = current_user.email
        rec.name          = current_user.last_name
        rec.given_names   = current_user.first_name
        rec.pesel         = current_user.pesel
        rec.birth_date    = current_user.birth_date.present? ? current_user.birth_date : decode_birth_date_from_pesel(current_user.pesel)
        rec.birth_place   = current_user.birth_city
        rec.family_name   = current_user.family_name
        rec.phone         = current_user.phone
        # old data - step2
        rec.address_id            = @proposal.address_id
        rec.city_name             = @proposal.city_name
        rec.street_name           = @proposal.street_name
        rec.c_address_house       = @proposal.c_address_house
        rec.c_address_number      = @proposal.c_address_number
        rec.c_address_postal_code = @proposal.c_address_postal_code
        # old data - step3
        rec.category                = @proposal.category
        rec.division_id             = @proposal.division_id
        rec.division_fullname       = @proposal.division_fullname
        rec.division_short_name     = @proposal.division_short_name
        rec.division_min_years_old  = @proposal.division_min_years_old
        # rec.exam_fee_id             = @proposal.exam_fee_id
        # rec.exam_fee_price          = @proposal.exam_fee_price
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_proposal
      @proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
      # @proposal = Proposal.find(params[:id])
    end

end

