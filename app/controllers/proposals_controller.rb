class ProposalsController < ApplicationController
  include ProposalsHelper
  
  before_action :authenticate_user!
  before_action :set_proposal, only: [:show, :edit, :update, :update_annulled]

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
    @proposal = Proposal.new(session_proposal_params)
    @proposal.current_step = session[:proposal_step]
    authorize @proposal, :create_self?

    if params[:back_button]
      @proposal.previous_step
    elsif @proposal.last_step?
      if @proposal.all_valid?
        @proposal.save_rec_and_push
      end
    else
      @proposal.next_step if @proposal.valid?
    end
    session[:proposal_step] = @proposal.current_step

    if @proposal.new_record?
      @proposal.esod_category = 41 if @proposal.current_step == 'step3'
      set_exam_fee_attributes if @proposal.current_step == 'step4'

      @proposal.confirm_that_the_data_is_correct = false
      render :new
    else
      session[:proposal_step] = session[:proposal_params] = nil
      flash[:success] = t('activerecord.successfull.messages.created', data: proposal_rec_info(@proposal))
      #redirect_to @proposal
      redirect_to proposals_url
    end
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

  def update_annulled
    @proposal.proposal_status_id = Proposal::PROPOSAL_STATUS_ANNULLED
    #authorize @proposal, :update_self?
    authorize @proposal, :create_self?

    respond_to do |format|
      if @proposal.save_rec_and_push
        flash[:warning] = t('activerecord.successfull.messages.annulled', data: proposal_rec_info(@proposal))
        format.html { redirect_to proposal_url }
      else
        @proposal.proposal_status_id_was
        format.html { render :show }
      end
    end
  end

  private

    def clear_attached_to_user_bank_pdf
      current_user.bank_pdf.purge if current_user.bank_pdf.attached?
      current_user.bank_pdf = nil
    end

    def clear_attached_to_user_face_image
      current_user.face_image.purge if current_user.face_image.attached?
      current_user.face_image = nil
    end

    def clear_attached_to_user_files
      clear_attached_to_user_bank_pdf
      clear_attached_to_user_face_image
    end

    def upload_bank_pdf_to_current_user_cache
      # # OK
      # uploaded_io = session[:proposal_params][:proposal][:bank_pdf]
      # File.open(Rails.root.join('public', 'tmp_uploads', "#{request.session_options[:id]}_bank_pdf_#{uploaded_io.original_filename}"), 'wb') do |file|
      #   file.write(uploaded_io.read)
      # end
      current_user.bank_pdf.attach(params[:proposal][:bank_pdf])
    end

    def upload_face_image_to_current_user_cache
      # # OK
      # uploaded_io = session[:proposal_params][:proposal][:face_image]
      # File.open(Rails.root.join('public', 'tmp_uploads', "#{request.session_options[:id]}_face_image_#{uploaded_io.original_filename}"), 'wb') do |file|
      #   file.write(uploaded_io.read)
      # end
      current_user.face_image.attach(params[:proposal][:face_image])
    end

    def set_init_user_profile_attributes
      @proposal.creator_id  = current_user.id
      @proposal.email       = current_user.email
      @proposal.name        = current_user.last_name
      @proposal.given_names = current_user.first_name
      @proposal.pesel       = current_user.pesel
      @proposal.birth_date  = current_user.birth_date
      @proposal.birth_place = current_user.birth_city
      @proposal.phone       = current_user.phone
    end

    def set_exam_fee_attributes
      exam_fee_obj = NetparExamFee.new(division_id: @proposal.division_id, esod_category: @proposal.esod_category)
      exam_fee_obj.request_find
     
      @proposal.exam_fee_id = exam_fee_obj.id
      @proposal.exam_fee_price = exam_fee_obj.price
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_proposal
      @proposal = Proposal.find_by(multi_app_identifier: params[:multi_app_identifier])
      # @proposal = Proposal.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def proposal_params
      params.require(:proposal).permit(:creator_id,
        :email, :phone, :name, :given_names, :pesel, :birth_date, :birth_place, 
        :address_city, :address_street, :address_house, :address_number, :address_postal_code,
        :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
        :category, :esod_category, :exam_id, :exam_fullname, :exam_date_exam, :division_id, :division_fullname, :division_min_years_old, 
        :exam_fee_id, :exam_fee_price, :face_image, :bank_pdf)
    end

    def session_proposal_params
      # clear attached face_image if change category and category not 'M' 
      if params[:proposal].present?
        if params[:proposal][:category].present?
          if params[:proposal][:category] != 'M'
            params[:proposal].extract!(:face_image)
            session[:proposal_params][:proposal].extract!(:face_image)
            clear_attached_to_user_face_image
          end
        end
      end

      if params[:proposal].present?
        upload_bank_pdf_to_current_user_cache if params[:proposal][:bank_pdf].present?
        params[:proposal].extract!(:bank_pdf)

        upload_face_image_to_current_user_cache if params[:proposal][:face_image].present?
        params[:proposal].extract!(:face_image)

        params[:proposal].reverse_merge!(session[:proposal_params][:proposal].permit!).merge!(params[:proposal].permit!) unless session[:proposal_params][:proposal].blank?
        session[:proposal_params] = params.deep_dup 
      else
        params[:proposal] = session[:proposal_params][:proposal]
      end

      params.require(:proposal).permit(:creator_id,
        :email, :phone, :name, :given_names, :pesel, :birth_date, :birth_place, 
        :address_city, :address_street, :address_house, :address_number, :address_postal_code,
        :c_address_city, :c_address_street, :c_address_house, :c_address_number, :c_address_postal_code,
        :category, :esod_category, :exam_id, :exam_fullname, :exam_date_exam, :division_id, :division_fullname, :division_min_years_old, 
        :exam_fee_id, :exam_fee_price, :confirm_that_the_data_is_correct)
    end

end

