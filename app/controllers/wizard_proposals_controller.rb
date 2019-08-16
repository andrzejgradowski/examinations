class WizardProposalsController < ApplicationController
  include ProposalsHelper
  
  before_action :authenticate_user!
  before_action :load_proposal_wizard, except: %i(validate_step)
  #after_action :verify_authorized, only: [:step1, :step2, :step3, :step4, :step5, :step6]
  after_action :verify_authorized, except: %i(validate_step)

  def step1
    set_user_profile_attributes
    authorize @proposal_wizard.proposal, :wizard?,  policy_class: ProposalPolicy
  end

  def step2
    # @proposal_wizard.proposal.creator_id = current_user.id
    authorize @proposal_wizard.proposal, :wizard?,  policy_class: ProposalPolicy
  end

  def step3
    # @proposal_wizard.proposal.creator_id = current_user.id
    @proposal_wizard.proposal.c_address_city        = @proposal_wizard.proposal.address_city        if @proposal_wizard.proposal.c_address_city.blank? 
    @proposal_wizard.proposal.c_address_street      = @proposal_wizard.proposal.address_street      if @proposal_wizard.proposal.c_address_street.blank?
    @proposal_wizard.proposal.c_address_house       = @proposal_wizard.proposal.address_house       if @proposal_wizard.proposal.c_address_house.blank?
    @proposal_wizard.proposal.c_address_number      = @proposal_wizard.proposal.address_number      if @proposal_wizard.proposal.c_address_number.blank?
    @proposal_wizard.proposal.c_address_postal_code = @proposal_wizard.proposal.address_postal_code if @proposal_wizard.proposal.c_address_postal_code.blank?

    authorize @proposal_wizard.proposal, :wizard?,  policy_class: ProposalPolicy
  end

  def step4
    # @proposal_wizard.proposal.creator_id = current_user.id
    authorize @proposal_wizard.proposal, :wizard?,  policy_class: ProposalPolicy
    # @proposal_wizard.proposal.exam_id = nil 
    # @proposal_wizard.proposal.exam_fullname = nil 
    # @proposal_wizard.proposal.date_exam = nil 
    # @proposal_wizard.proposal.division_id = nil
    # @proposal_wizard.proposal.division_fullname = nil
  end

  def step5
    # @proposal_wizard.proposal.user_id = current_user.id
    authorize @proposal_wizard.proposal, :wizard?,  policy_class: ProposalPolicy
  end


  def validate_step
    current_step = params[:current_step]

    @proposal_wizard = wizard_proposal_for_step(current_step)
    @proposal_wizard.proposal.attributes = proposal_wizard_params
    # set
    # TODO
    set_user_profile_attributes

    session[:proposal_attributes] = @proposal_wizard.proposal.attributes

    if @proposal_wizard.valid?
      next_step = wizard_proposal_next_step(current_step)
      create and return unless next_step

      redirect_to action: next_step
    else
      render current_step
    end
  end

  def create
    authorize @proposal_wizard.proposal, :wizard?,  policy_class: ProposalPolicy
    if @proposal_wizard.proposal.save
      flash[:success] = t('activerecord.successfull.messages.created', data: proposal_rec_info(@proposal_wizard))
      session[:proposal_attributes] = nil
      @proposal_wizard = nil
      redirect_to proposals_path
    else
      redirect_to({ action: Wizards::Proposal::STEPS.first }, alert: t('activerecord.errors.messages.created'))
    end
  end

  private

    def load_proposal_wizard
      @proposal_wizard = wizard_proposal_for_step(action_name)
    end

    def set_user_profile_attributes
      @proposal_wizard.proposal.creator_id  = current_user.id
      @proposal_wizard.proposal.email       = current_user.email
      @proposal_wizard.proposal.name        = current_user.last_name
      @proposal_wizard.proposal.given_names = current_user.first_name
      @proposal_wizard.proposal.pesel       = current_user.pesel
      @proposal_wizard.proposal.birth_date  = current_user.birth_date if @proposal_wizard.proposal.birth_date.blank?
      @proposal_wizard.proposal.birth_place = current_user.birth_city if @proposal_wizard.proposal.birth_place.blank?
      @proposal_wizard.proposal.phone       = current_user.phone      if @proposal_wizard.proposal.phone.blank?
    end

    def wizard_proposal_next_step(step)
      Wizards::Proposal::STEPS[Wizards::Proposal::STEPS.index(step) + 1]
    end

    def wizard_proposal_for_step(step)
      raise InvalidStep unless step.in?(Wizards::Proposal::STEPS)

      "Wizards::Proposal::#{step.camelize}".constantize.new(session[:proposal_attributes])
    end

    def proposal_wizard_params
      params.require(:proposal_wizard).permit(:category, :creator_id,
        :email, :phone, :name, :given_names, :pesel, :birth_date, :birth_place, 
        :address_city, :address_street, :address_house, :address_number, :address_postal_code,
        :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
        :esod_category, :exam_id, :exam_fullname, :date_exam, :division_id, :division_fullname)
    end

  class InvalidStep < StandardError; end
end
