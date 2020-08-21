class Proposals::WizardStepsController < ApplicationController
  include ProposalsHelper
  include Wicked::Wizard

  before_action :authenticate_user!
  #after_action :verify_authorized

  respond_to :html

  steps *Proposal.form_steps
  
  def show
    @proposal = Proposal.find_by(multi_app_identifier: params[:proposal_multi_app_identifier])
    authorize @proposal, :show_self?, policy_class: ProposalPolicy if @proposal.present?
    render_wizard
  end

  def update
    @proposal = Proposal.find_by(multi_app_identifier: params[:proposal_multi_app_identifier])

    authorize @proposal, :create_self?, policy_class: ProposalPolicy if @proposal.present?

    unless step == steps.last
      params[:proposal][:status] = step.to_s
      @proposal.update(proposal_params(step))
    else
      @proposal.status = Proposal::REQUIRED_PUSH_TO_NETPAR
      @proposal.confirm_that_the_data_is_correct = params[:proposal][:confirm_that_the_data_is_correct]     
      #@proposal.update(proposal_params(step))
    end
    render_wizard @proposal
  end

  private

    def finish_wizard_path
      flash[:success] = t('activerecord.successfull.messages.created', data: proposal_rec_info(@proposal))
      proposals_path
    end

    def proposal_params(step)
      permitted_attributes = case step
                             when "step1"
                               [:status, :email, :name, :given_names, :pesel, :citizenship_code, :birth_place, :birth_date, :family_name, :phone, :creator_id]
                             when "step2"
                               [:status, :lives_in_poland, :address_combine_id, :city_name, :street_name, :c_address_house, :c_address_number, :c_address_postal_code]
                             when "step3"
                               [:status, :category, :division_id, :exam_id, :division_fullname, :division_short_name, :division_min_years_old, :exam_fullname, :exam_date_exam, :exam_fee_id, :exam_fee_price]
                             when "step4"
                               [:status, :bank_pdf, :face_image, :consent_pdf]
                             when "step5"
                               [:status, :confirm_that_the_data_is_correct]
                             end

      params.require(:proposal).permit(permitted_attributes).merge(form_step: step)
    end

end
