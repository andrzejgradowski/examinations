require 'net/http'

class Proposal < ApplicationRecord

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
  PROPOSAL_STATUS_PAYED = 4
  PROPOSAL_STATUS_CLOSED = 5

  PROPOSAL_STATUSES = [PROPOSAL_STATUS_CREATED, PROPOSAL_STATUS_APPROVED, PROPOSAL_STATUS_NOT_APPROVED, PROPOSAL_STATUS_PAYED, PROPOSAL_STATUS_CLOSED]

  CATEGORY_NAME_M = "Świadectwo służby morskiej i żeglugi śródlądowej"
  CATEGORY_NAME_R = "Świadectwo służby radioamatorskiej"

  attr_writer :current_step, :all_is_ok

  # relations
  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  has_one_attached :face_image
  has_one_attached :bank_pdf

  # validates

  validates :creator, presence: true
  validates :proposal_status_id, presence: true, inclusion: { in: PROPOSAL_STATUSES }

  # step 1
  # validates :email, presence: true, format: { with: /@/ }, if: -> { current_step == 'step1' }
  # validates :name, presence: true, length: { in: 1..160 }, if: -> { current_step == 'step1' }
  # validates :given_names, presence: true, length: { in: 1..50 }, if: -> { current_step == 'step1' }
  # validates :birth_place, presence: true, length: { in: 1..50 }, if: -> { current_step == 'step1' }
  # validates :birth_date, presence: true, if: -> { current_step == 'step1' }
  # validate :check_pesel, if: -> { current_step == 'step1' && pesel.present? }
  # validate :check_birth_date, if: -> { current_step == 'step1' && pesel.present? }
  # OR:
  with_options if: -> { current_step == 'step1' } do |step|
    step.validates :email, presence: true, format: { with: /@/ }
    step.validates :name, presence: true, length: { in: 1..160 }
    step.validates :given_names, presence: true, length: { in: 1..50 }
    step.validates :birth_place, presence: true, length: { in: 1..50 }
    step.validates :birth_date, presence: true
    step.validate :check_pesel, if: -> { pesel.present? }
    step.validate :check_birth_date, if: -> { pesel.present? }
  end

  # step2
  with_options if: -> { current_step == 'step2' } do |step|
    step.validates :address_city, presence: true, length: { in: 1..50 }
    step.validates :address_house, presence: true, length: { in: 1..10 }
    step.validates :address_postal_code, presence: true, length: { in: 6..10 }
  end

  # step3
  with_options if: -> { current_step == 'step3' } do |step|
    step.validates :c_address_city, presence: true, length: { in: 1..50 }
    step.validates :c_address_house, presence: true, length: { in: 1..10 }
    step.validates :c_address_postal_code, presence: true, length: { in: 6..10 }
  end

  # step4
  with_options if: -> { current_step == 'step4' } do |step|
    step.validates :category, presence: true, inclusion: { in: %w(M R) }
    step.validate :unique_category_for_creator, if: -> { category.present?}
    step.validates :exam_id, presence: true
    step.validates :division_id, presence: true
    step.validate :check_min_years_old, if: -> { division_id.present? }

    step.validates :esod_category, presence: true
  end

  # step5
  with_options if: -> { current_step == 'step5' } do |step|
    step.validate :check_attached_bank_pdf
    step.validate :check_attached_face_image
  end

  # step6
  validates :exam_fee_id, presence: true, if: -> { current_step == 'step6' && esod_category.present? && division_id.present? }
  validates :exam_fee_price, presence: true, if: -> { current_step == 'step6' && esod_category.present? && division_id.present? }

  # callbacks
  after_initialize :set_initial_status_and_multi_app_identifier

  def steps
    %w[step1 step2 step3 step4 step5 step6]
  end

  def current_step
    @current_step || steps.first
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end 


  def save
    return false if invalid?
    ApplicationRecord.transaction do
#    Proposal.transaction do
      if new_record?
        # Insert data to Netpar2015
        netpar_proposal_obj = NetparProposal.new(netpar_proposal: JSON.parse(self.to_json) )
        response = netpar_proposal_obj.request_create
      else
        netpar_proposal_obj = NetparProposal.new(multi_app_identifier: self.multi_app_identifier, netpar_proposal: JSON.parse(self.to_json) )
        response = netpar_proposal_obj.request_update
      end

    rescue *HTTP_ERRORS => e
      Rails.logger.error('======== API ERROR "models/proposal/save - API ERROR" (1) ===================')
      Rails.logger.error("#{e}")
      errors.add(:base, "#{e}")
      Rails.logger.error('=============================================================================')
      raise ActiveRecord::Rollback, "#{e}"
      false
    rescue StandardError => e
      Rails.logger.error('======== API ERROR "models/proposal/save - API ERROR" (2) ===================')
      Rails.logger.error("#{e}")
      errors.add(:base, "#{e}")
      Rails.logger.error('=============================================================================')
      raise ActiveRecord::Rollback, "#{e}"
      false
    else
      case response
      when Net::HTTPOK, Net::HTTPCreated
        #save!
        super
        true   # success response
      when Net::HTTPClientError, Net::HTTPInternalServerError
        Rails.logger.error('======== API ERROR "models/proposal/save" (3) ===============================')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      when response.class != 'String'
        Rails.logger.error('======== API ERROR "models/proposal/save" (4) ===============================')
        Rails.logger.error("code: #{response.code}, message: #{response.message}, body: #{response.body}")
        errors.add(:base, "code: #{response.code}, message: #{response.message}, body: #{response.body}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{e}"
        false
      else
        Rails.logger.error('======== API ERROR "models/proposal/save" (5) ===============================')
        Rails.logger.error("#{response}")
        errors.add(:base, "#{response}")
        Rails.logger.error('=============================================================================')
        raise ActiveRecord::Rollback, "#{response}"
        false
      end
    end
  rescue  => exception
    Rails.logger.error('============= ERROR models/proposal/save =======================================')
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
  
  def destroy
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
        self.face_image.purge
        self.bank_pdf.purge
        super
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
  

  def status_name
    case proposal_status_id
    when PROPOSAL_STATUS_CREATED
      'Zgłoszenie utworzone'
    when PROPOSAL_STATUS_APPROVED
      'Zgłoszenie zatwierdzone'
    when PROPOSAL_STATUS_NOT_APPROVED
      'Zgłoszenie odrzucone'
    when PROPOSAL_STATUS_PAYED
      'Zgłoszenie opłacone'
    when PROPOSAL_STATUS_CLOSED
      'Zgłoszenie zamknięte'
    when 0, nil
      ''
    else
      'Error !'
    end  
  end

  def can_destroy?
    proposal_status_id != PROPOSAL_STATUS_CLOSED
  end

  def can_edit?
    proposal_status_id != PROPOSAL_STATUS_CLOSED
  end

  def division_face_image_required
    category == 'M' 
  end

  private
  
    def set_initial_status_and_multi_app_identifier
      self.proposal_status_id = PROPOSAL_STATUS_CREATED unless self.proposal_status_id.present?
      self.multi_app_identifier = SecureRandom.uuid unless self.multi_app_identifier.present?
    end

    def check_pesel
      unless Activepesel::Pesel.new(pesel).valid?
        errors.add(:pesel, " - jest niepoprawny")
        false
      end
    end
    def check_birth_date
      unless Activepesel::Pesel.new(pesel).date_of_birth == birth_date
        errors.add(:birth_date, " - niezgodność danych z danymi PESEL")
        false
      end
    end

    def unique_category_for_creator
      if Proposal.where(category: category, creator_id: creator_id).where.not(proposal_status_id: [::Proposal::PROPOSAL_STATUS_CLOSED]).any? 
        errors.add(:category, " - Jest aktualnie procedowane Twoje zgłoszenie dla tej służby")
        false
      end
    end

    def check_min_years_old
      division_obj = NetparDivision.new(id: division_id)
      division_obj_response = division_obj.request_with_id
      division_min_years_old = JSON.parse(division_obj_response.body)['min_years_old']
      if (birth_date + division_min_years_old.years) > Time.zone.now
        errors.add(:division_id, " - Przystąpienie do egzaminu wymaga ukończenia #{division_min_years_old} lat")
        false
      else
        true
      end
    end

    def check_attached_bank_pdf
      analyze_value = true
      unless self.creator.bank_pdf.attached?
        errors.add(:bank_pdf, ' - wymaga dodania pliku (plik content_type ["application/pdf"])')
        analyze_value = false
      else
        unless ['application/pdf'].include?(self.creator.bank_pdf.blob.content_type)
          errors.add(:bank_pdf, ' - nieprawidłowy typ pliku (plik content_type ["application/pdf"])')
          analyze_value = false
        else
          unless self.creator.bank_pdf.blob.byte_size < 300000
            errors.add(:bank_pdf, ' - plik jest za duży (max 300kB)')
            analyze_value = false
          else
           analyze_value = true
          end
        end
      end
      analyze_value
    end

    def check_attached_face_image
      analyze_value = true
      unless self.division_face_image_required
        analyze_value = true
      else
        unless self.creator.face_image.attached?
          errors.add(:face_image, ' - wymaga dodania pliku (plik content_type ["image/jpeg", "image/png"])')
          analyze_value = false
        else
          unless ['image/jpeg','image/png'].include?(self.creator.face_image.blob.content_type)
            errors.add(:face_image, ' - nieprawidłowy typ pliku (plik content_type ["image/jpeg", "image/png"])')
            analyze_value = false
          else
            unless self.creator.face_image.blob.byte_size < 300000
              errors.add(:face_image, ' - plik jest za duży (max 300kB)')
              analyze_value = false
            else
             analyze_value = true
            end
          end
        end
      end
      analyze_value
    end


end
