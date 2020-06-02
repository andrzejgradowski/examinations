require 'net/http'

class Proposal < ApplicationRecord

  ESOD_CATEGORY_EGZAMIN = 41
  ESOD_CATEGORY_POPRAWKOWY = 42
  ESOD_ODNOWIENIE_Z_EGZAMINEM = 44 
  ESOD_ODNOWIENIE_Z_EGZAMINEM_POPRAWKOWY = 49

  ESOD_CATEGORY_EGZAMIN_NAME = "Wniosek o przeprowadzenie egzaminu i wydanie świadectwa"
  ESOD_CATEGORY_POPRAWKOWY_NAME = "Wniosek o przeprowadzenie egzaminu poprawkowego i wydanie świadectwa"

  HTTP_ERRORS = [
    EOFError,
    Errno::ECONNRESET,
    Errno::EINVAL,
    Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError,
    Net::ProtocolError,
    Timeout::Error,
    Errno::ECONNREFUSED
  ]

  PROPOSAL_STATUS_CREATED = 1
  PROPOSAL_STATUS_APPROVED = 2
  PROPOSAL_STATUS_NOT_APPROVED = 3
  PROPOSAL_STATUS_CLOSED = 4
  PROPOSAL_STATUS_ANNULLED = 5
  PROPOSAL_STATUS_EXAMINATION_RESULT_B = 6  # "Negatywny bez prawa do poprawki" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_N = 7  # "Negatywny z prawem do poprawki" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_O = 8  # "Nieobecny" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_P = 9  # "Pozytywny" 
  PROPOSAL_STATUS_EXAMINATION_RESULT_Z = 10 # "Zmiana terminu" 

  PROPOSAL_STATUSES = [ PROPOSAL_STATUS_CREATED, 
                        PROPOSAL_STATUS_APPROVED, 
                        PROPOSAL_STATUS_NOT_APPROVED, 
                        PROPOSAL_STATUS_CLOSED, 
                        PROPOSAL_STATUS_ANNULLED,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_B,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_N,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_O,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_P,
                        PROPOSAL_STATUS_EXAMINATION_RESULT_Z ]

  PROPOSAL_STATUSES_WITH_COMMENT = [ PROPOSAL_STATUS_NOT_APPROVED, 
                                     PROPOSAL_STATUS_CLOSED ]

  CATEGORY_NAME_M = "Świadectwo służby morskiej i żeglugi śródlądowej"
  CATEGORY_NAME_R = "Świadectwo służby radioamatorskiej"

  SAVED_IN_NETPAR = 'saved_in_netpar'
  REQUIRED_PUSH_TO_NETPAR = 'required_push_to_netpar'

  cattr_accessor :form_steps do
    %w(step1 step2 step3 step4 step5)
  end

  attr_accessor :form_step

  # relations
  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  has_one_attached :bank_pdf
  has_one_attached :face_image
  has_one_attached :consent_pdf

  # validates
  validates :creator, presence: true
  validates :proposal_status_id, presence: true, inclusion: { in: PROPOSAL_STATUSES }
  validates :esod_category, presence: true

  # step 1
  # validates :email, presence: true, format: { with: /@/ }, if: -> { current_step == 'step1' }
  validates :email, presence: true, format: { with: /@/ }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :name, presence: true, length: { in: 1..160 }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :given_names, presence: true, length: { in: 1..50 }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :citizenship_code, presence: true, length: { in: 1..50 }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :phone, length: { maximum: 50 }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :birth_place, presence: true, length: { in: 1..50 }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :birth_date, presence: true, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validates :family_name, presence: true, length: { in: 1..50 }, if: -> { required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validate :check_pesel, if: -> { pesel.present? && required_for_step?(:step1) && status != SAVED_IN_NETPAR }
  validate :check_birth_date, if: -> { pesel.present? && required_for_step?(:step1) && status != SAVED_IN_NETPAR }

  # step2
  validates :address_id, presence: true, if: -> { lives_in_poland == true && required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  validates :city_name, presence: true, length: { in: 1..50 }, if: -> { lives_in_poland == false && required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  validates :street_name, length: { maximum: 50 }, if: -> { lives_in_poland == false && required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  validates :c_address_house, presence: true, length: { in: 1..10 }, if: -> { required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  validates :c_address_number, length: { maximum: 10 }, if: -> { required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  validates :c_address_postal_code, presence: true, length: { in: 6..10 }, if: -> { required_for_step?(:step2) && status != SAVED_IN_NETPAR }

  # step3
  validates :category, presence: true, inclusion: { in: %w(M R) }, if: -> { required_for_step?(:step3) && status != SAVED_IN_NETPAR }
  validates :division_id, presence: true, if: -> { required_for_step?(:step3) }
  validates :exam_id, presence: true, if: -> { required_for_step?(:step3) }
  validate :unique_division_for_creator, if: -> { division_id.present? && required_for_step?(:step3) && status != SAVED_IN_NETPAR }
  validate :check_min_years_old, if: -> { division_min_years_old.present? && required_for_step?(:step3) && status != SAVED_IN_NETPAR }

  validates :exam_fee_id, presence: true, if: -> { esod_category.present? && division_id.present? && required_for_step?(:step3) && status != SAVED_IN_NETPAR }
  validates :exam_fee_price, presence: true, if: -> { esod_category.present? && division_id.present? && required_for_step?(:step3) && status != SAVED_IN_NETPAR }

  # step4
  validate :check_required_bank_pdf, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR }
  validate :check_attached_bank_pdf, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR }
  validate :check_required_face_image, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR }
  validate :check_attached_face_image, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR }
  validate :check_required_consent_pdf, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR }
  validate :check_attached_consent_pdf, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR }

  # step5
  validate :check_confirm_that_the_data_is_correct, if: -> { required_for_step?(form_steps.last) && status != SAVED_IN_NETPAR }
  #validate :validate_saved_api, if: -> { (confirm_that_the_data_is_correct == true) && (status == form_steps.last.to_s) }


  # callbacks
  after_initialize :set_initial_status_and_multi_app_identifier
  before_validation :put_address_values, if: -> { lives_in_poland == true && required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  before_validation :clear_address_values, if: -> { lives_in_poland == false && required_for_step?(:step2) && status != SAVED_IN_NETPAR }
  before_validation :put_exam_fee_values, if: -> { required_for_step?(:step3) && status != SAVED_IN_NETPAR }
  before_validation :purge_unrequired_files, if: -> { required_for_step?(:step3) && status != SAVED_IN_NETPAR }
  before_validation :update_link_for_attached_files, if: -> { required_for_step?(:step4) && status != SAVED_IN_NETPAR } 
  after_validation :after_validation_saved_in_netpar, if: -> { confirm_that_the_data_is_correct == true && status == REQUIRED_PUSH_TO_NETPAR }
  after_save :send_notification, if: -> { status == SAVED_IN_NETPAR }

  def required_for_step?(step)
    return true if form_step.nil?
    return true if self.form_steps.index(step.to_s) <= self.form_steps.index(form_step)
  end

  def save_rec_and_push(action)
    # return false if invalid?
    ApplicationRecord.transaction do
      if action == 'create'
        # Insert data to Netpar2015
        netpar_proposal_obj = NetparProposal.new(netpar_proposal: JSON.parse(self.to_json) )
        response = netpar_proposal_obj.request_create
      else
        # Update data to Netpar2015
        netpar_proposal_obj = NetparProposal.new(multi_app_identifier: self.multi_app_identifier, netpar_proposal: JSON.parse(self.to_json) )
        response = netpar_proposal_obj.request_update
      end

    rescue *HTTP_ERRORS => e
      Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (1) =======')
      Rails.logger.error("#{e}")
      errors.add(:base, "#{e}")
      Rails.logger.error('=============================================================================')
      raise ActiveRecord::Rollback, "#{e}"
      false
    rescue StandardError => e
      Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (2) =======')
      Rails.logger.error("#{e}")
      errors.add(:base, "#{e}")
      Rails.logger.error('=============================================================================')
      raise ActiveRecord::Rollback, "#{e}"
      false
    else
      case response
      when Net::HTTPOK, Net::HTTPCreated
        save!
        true   # success response
      when Net::HTTPNoContent
        Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (3) =======')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      when Net::HTTPClientError, Net::HTTPInternalServerError
        Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (4) =======')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      when response.class != 'String'
        Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (5) =======')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      else
        Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (6) =======')
        Rails.logger.error("#{response}")
        errors.add(:base, "#{response}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{response}"
        false
      end
    end
  rescue  => exception
    Rails.logger.error('======= API ERROR "models/proposal/save_rec_and_push - API ERROR" (7) =======')
    Rails.logger.error('... rescue => exception')
    Rails.logger.error("... #{exception.message}")
    Rails.logger.error("... #{exception.couse.message}")
    # Handle exception that caused the transaction to fail
    # e.message and e.cause.message can be helpful
    errors.add(:base, "#{exception.message}")
    errors.add(:base, "#{exception.couse.message}")
    Rails.logger.error('==============================================================================')
    false
  end
  
  def destroy_and_push
    return false if invalid?
    ApplicationRecord.transaction do
#    Proposal.transaction do
      netpar_proposal_obj = NetparProposal.new(multi_app_identifier: self.multi_app_identifier, netpar_proposal: JSON.parse(self.to_json) )
      response = netpar_proposal_obj.request_destroy

    rescue *HTTP_ERRORS => e
      Rails.logger.error('======== API ERROR "models/proposal/destroy - API ERROR" (1) ================')
      Rails.logger.error("#{e}")
      errors.add(:base, "#{e}")
      Rails.logger.error('=============================================================================')
      raise ActiveRecord::Rollback, "#{e}"
      false
    rescue StandardError => e
      Rails.logger.error('======== API ERROR "models/proposal/destroy - API ERROR" (2) ================')
      Rails.logger.error("#{e}")
      errors.add(:base, "#{e}")
      Rails.logger.error('=============================================================================')
      raise ActiveRecord::Rollback, "#{e}"
      false
    else
      case response
      when Net::HTTPNoContent
        #with_transaction_returning_status { super }
        self.bank_pdf.purge_later
        self.face_image.purge_later
        self.consent_pdf.purge_later
        #super
        destroy!
        true   # success response
      when Net::HTTPClientError, Net::HTTPInternalServerError
        Rails.logger.error('======== API ERROR "models/proposal/destroy" (3) ============================')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      when response.class != 'String'
        Rails.logger.error('======== API ERROR "models/proposal/destroy" (4) ============================')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      else
        Rails.logger.error('======== API ERROR "models/proposal/destroy" (5) ============================')
        Rails.logger.error("#{response}")
        errors.add(:base, "#{response}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{response}"
        false
      end
    end
  rescue  => exception
    Rails.logger.error('============= ERROR models/proposal/destroy ====================================')
    Rails.logger.error('... rescue => exception')
    Rails.logger.error("... #{exception.message}")
    Rails.logger.error("... #{exception.couse.message}")
    # Handle exception that caused the transaction to fail
    # e.message and e.cause.message can be helpful
    errors.add(:base, "#{exception.message}")
    errors.add(:base, "#{exception.couse.message}")
    Rails.logger.error('================================================================================')
    false
  end
  
  def can_annulled?
    (exam_date_exam - 5.days > Time.zone.today) && [PROPOSAL_STATUS_CREATED, PROPOSAL_STATUS_APPROVED].include?(proposal_status_id) 
  end

  def can_correction_exam?
    [PROPOSAL_STATUS_EXAMINATION_RESULT_N].include?(proposal_status_id)
  end

  def bank_pdf_required?
    true
  end

  def face_image_required?
    category == 'M' 
  end

  def consent_pdf_required?
    birth_date >= Time.zone.today - 18.years
  end

  def send_notification
    if (saved_change_to_proposal_status_id? || saved_change_to_status?)
      case proposal_status_id
      when PROPOSAL_STATUS_CREATED
        ProposalMailer.created(self).deliver_later
      when PROPOSAL_STATUS_APPROVED
        ProposalMailer.approved(self).deliver_later
      when PROPOSAL_STATUS_NOT_APPROVED
        ProposalMailer.not_approved(self).deliver_later      
      when PROPOSAL_STATUS_CLOSED
        ProposalMailer.closed(self).deliver_later      
      when PROPOSAL_STATUS_ANNULLED
        ProposalMailer.annulled(self).deliver_later      
      when PROPOSAL_STATUS_EXAMINATION_RESULT_B
        ProposalMailer.examination_result_b(self).deliver_later      
      when PROPOSAL_STATUS_EXAMINATION_RESULT_N
        ProposalMailer.examination_result_n(self).deliver_later      
      when PROPOSAL_STATUS_EXAMINATION_RESULT_O
        ProposalMailer.examination_result_o(self).deliver_later      
      when PROPOSAL_STATUS_EXAMINATION_RESULT_P
        ProposalMailer.examination_result_p(self).deliver_later      
      when PROPOSAL_STATUS_EXAMINATION_RESULT_Z
        ProposalMailer.examination_result_z(self).deliver_later      
      end
    end
  end

  def self.send_reminders
    puts '--------------------------------------------------------------------------------'    
    puts 'RUN WHENEVER send_reminders...'
    start_run = Time.current

    proposals = Proposal.where(proposal_status_id: Proposal::PROPOSAL_STATUS_APPROVED, exam_date_exam: (Time.zone.today + 3.days)).order(:id).all
    proposals_size = proposals.size
    proposals.each do |rec|
      ProposalMailer.reminder(rec).deliver
      puts "id: #{rec.id}    #{rec.email}, #{rec.name} #{rec.given_names}"
    end

    puts "START: #{start_run.strftime('%Y-%m-%d %H:%M:%S')}  END: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}   SEND EMAILS: #{proposals_size}"
    puts '--------------------------------------------------------------------------------'    
  end

  def self.clean_unsaved
    puts '--------------------------------------------------------------------------------'    
    puts 'RUN WHENEVER clean_unsaved...'
    start_run = Time.current

    check_date = Time.zone.today - 30.days
    proposals = Proposal.where(proposal_status_id: Proposal::PROPOSAL_STATUS_CREATED, confirm_that_the_data_is_correct: false).where('updated_at <= :check_date', {check_date: check_date}).
                        where.not(status: Proposal::SAVED_IN_NETPAR).order(:id).all
    proposals_size = proposals.size
    proposals.each do |rec|
      puts "id: #{rec.id}    status: #{rec.status} - #{rec.email}, #{rec.name} #{rec.given_names}"
      rec.destroy 
    end

    puts "START: #{start_run.strftime('%Y-%m-%d %H:%M:%S')}  END: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}   DESTROYED: #{proposals_size}"
    puts '--------------------------------------------------------------------------------'    
  end

  private
  
    def set_initial_status_and_multi_app_identifier
      self.proposal_status_id = PROPOSAL_STATUS_CREATED unless self.proposal_status_id.present?
      self.multi_app_identifier = SecureRandom.uuid unless self.multi_app_identifier.present?
    end

    def put_address_values
      if self.address_id.present?
        item_obj = PitTerytItem.new(id: self.address_id)
        if item_obj.request_for_one_row
          item_values = JSON.parse(item_obj.response.body)

          self.province_code = item_values["provinceCode"]
          self.province_name = item_values["provinceName"]
          self.district_code = item_values["districtCode"]
          self.district_name = item_values["districtName"]
          self.commune_code = item_values["communeCode"]
          self.commune_name = item_values["communeName"]
          self.city_code = item_values["cityCode"]
          self.city_name = item_values["cityName"]
          self.city_parent_code = item_values["cityParentCode"] if item_values["cityParentCode"].present?
          self.city_parent_name = item_values["cityParentName"] if item_values["cityParentName"].present?
          self.street_code = item_values["streetCode"] if item_values["streetCode"].present?
          self.street_name = item_values["streetName"] if item_values["streetName"].present?
          self.street_attribute = item_values["streetAttribute"] if item_values["streetAttribute"].present?
          self.teryt_code = item_values["terytId"]
        else
          item_obj.errors.full_messages.each do |msg|
            self.errors.add(:base, msg.force_encoding("UTF-8"))
          end
        end
      end
    end

    def clear_address_values
      self.address_id = nil
      self.province_code = ""
      self.province_name = ""
      self.district_code = ""
      self.district_name = ""
      self.commune_code = ""
      self.commune_name = ""
      self.city_code = ""
      #self.city_name = item_values["cityName"]
      self.city_parent_code = ""
      self.city_parent_name = ""
      self.street_code = ""
      #self.street_name = item_values["streetName"] if item_values["streetName"].present?
      self.street_attribute = ""
      self.teryt_code = ""
    end

    def put_exam_fee_values
      exam_fee_obj = NetparExamFee.new(division_id: self.division_id, esod_category: self.esod_category)
      if exam_fee_obj.request_find # return true
        response_hash = JSON.parse(exam_fee_obj.response.body)
        self.exam_fee_id = response_hash['id']
        self.exam_fee_price = response_hash['price']
      else
        exam_fee_obj.errors.full_messages.each do |msg|
          self.errors.add(:base, msg.force_encoding("UTF-8"))
        end        
      end
    end

    def purge_unrequired_files
      unless self.face_image_required?
        self.face_image.purge_later if self.face_image.attached?
        self.face_image_blob_path = nil
      end

      unless self.consent_pdf_required?
        self.consent_pdf.purge_later if self.consent_pdf.attached?
        self.consent_pdf_blob_path = nil
      end
    end

    def update_link_for_attached_files
      self.bank_pdf_blob_path     = Rails.application.routes.url_helpers.rails_blob_path(self.bank_pdf) if self.bank_pdf.attached?
      self.face_image_blob_path   = Rails.application.routes.url_helpers.rails_blob_path(self.face_image) if self.face_image.attached?
      self.consent_pdf_blob_path  = Rails.application.routes.url_helpers.rails_blob_path(self.consent_pdf) if self.consent_pdf.attached?
    end

    def check_pesel
      errors.add(:pesel, " - jest niepoprawny") unless Activepesel::Pesel.new(pesel).valid?
    end

    def check_birth_date
      errors.add(:birth_date, " - niezgodność danych z danymi PESEL") unless Activepesel::Pesel.new(pesel).date_of_birth == birth_date
    end

    def unique_division_for_creator
      if Proposal.where(division_id: division_id, creator_id: creator_id, proposal_status_id: [PROPOSAL_STATUS_CREATED, PROPOSAL_STATUS_APPROVED], confirm_that_the_data_is_correct: true).where.not(id: self.id).any? 
        errors.add(:division_id, " - Jest aktualnie procedowane Twoje zgłoszenie dla tego typu świadectwa")
        false
      end
    end

    def check_min_years_old
      errors.add(:division_id, " - Przystąpienie do egzaminu wymaga ukończenia #{division_min_years_old} lat") if (birth_date + division_min_years_old.years) > Time.zone.now
    end

    def check_required_bank_pdf
      if self.bank_pdf_required? 
        errors.add(:bank_pdf, ' - wymaga dodania pliku typu PDF') unless self.bank_pdf.attached?
        false
      end
    end

    def check_required_face_image
      if self.face_image_required? 
        errors.add(:face_image, ' - wymaga dodania pliku typu JPG/JPEG/PNG') unless self.face_image.attached?
      end
    end

    def check_required_consent_pdf
      if self.consent_pdf_required? 
        errors.add(:consent_pdf, ' - wymaga dodania pliku typu PDF') unless self.consent_pdf.attached?
      end
    end

    def check_attached_bank_pdf
      if self.bank_pdf.attached?
        unless ['application/pdf'].include?(self.bank_pdf.blob.content_type)
          errors.add(:bank_pdf, ' - nieprawidłowy typ pliku (wymagany typ PDF)')
        else
          errors.add(:bank_pdf, ' - plik jest za duży (max 600kB)') if self.bank_pdf.blob.byte_size > 600000
        end
      end
    end

    def check_attached_face_image
      if self.face_image.attached?
        unless ['image/jpg','image/jpeg','image/png'].include?(self.face_image.blob.content_type)
          errors.add(:face_image, ' - nieprawidłowy typ pliku (wymagany typ JPG/JPEG/PNG)')
        else
          errors.add(:face_image, ' - plik jest za duży (max 2MB)') if self.face_image.blob.byte_size > 2000000
        end
      end
    end

    def check_attached_consent_pdf
      if self.consent_pdf.attached?
        unless ['application/pdf'].include?(self.consent_pdf.blob.content_type)
          errors.add(:consent_pdf, ' - nieprawidłowy typ pliku (wymagany typ PDF)')
        else
          errors.add(:consent_pdf, ' - plik jest za duży (max 600kB)') if self.consent_pdf.blob.byte_size > 600000
        end
      end
    end

    def check_confirm_that_the_data_is_correct
      errors.add(:confirm_that_the_data_is_correct, " - Musisz potwierdzić poprawność danych") unless confirm_that_the_data_is_correct == true
    end

    def after_validation_saved_in_netpar
      self.status = SAVED_IN_NETPAR
      self.save_rec_and_push('create')
    end  

end
