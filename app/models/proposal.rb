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

  PROPOSAL_CREATED = 1
  PROPOSAL_APPROVED = 2
  PROPOSAL_NOT_APPROVED = 3
  PROPOSAL_PAYED = 4
  PROPOSAL_CLOSED = 5

  PROPOSAL_STATUSES = [PROPOSAL_CREATED, PROPOSAL_APPROVED, PROPOSAL_NOT_APPROVED, PROPOSAL_PAYED, PROPOSAL_CLOSED]

  CATEGORY_NAME_M = "Świadectwo służby morskiej i żeglugi śródlądowej"
  CATEGORY_NAME_R = "Świadectwo służby radioamatorskiej"

  # relations
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  # validates
  validates :status, presence: true, inclusion: { in: PROPOSAL_STATUSES }
  validates :category, presence: true, inclusion: { in: %w(M R) },
                    uniqueness: { conditions: -> { where.not(status: [PROPOSAL_CLOSED]) }, 
                                  scope: [:creator_id], message: " - Jest aktualnie procedowane Twoje zgłoszenie dla tej służby" }

  validates :email, presence: true, format: { with: /@/ }
  validates :name, presence: true, length: { in: 1..160 }
  validates :given_names, presence: true, length: { in: 1..50 }
  validates :address_city, presence: true, length: { in: 1..50 }
  validates :address_house, presence: true, length: { in: 1..10 }
  validates :address_postal_code, presence: true, length: { in: 6..10 }
  validates :birth_place, presence: true, length: { in: 1..50 }
  validates :birth_date, presence: true
  validates :creator, presence: true

  # callbacks
  after_initialize :set_initial_status_and_multi_app_identifier

  def save
    return false if invalid?
#    ApplicationRecord.transaction do
    Proposal.transaction do
      if new_record?
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
        save!
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
#    ApplicationRecord.transaction do
    Proposal.transaction do
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
        with_transaction_returning_status { super }
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
    case status
    when PROPOSAL_CREATED
      'Zgłoszenie utworzone'
    when PROPOSAL_APPROVED
      'Zgłoszenie zatwierdzone'
    when PROPOSAL_NOT_APPROVED
      'Zgłoszenie odrzucone'
    when PROPOSAL_PAYED
      'Zgłoszenie opłacone'
    when PROPOSAL_CLOSED
      'Zgłoszenie zamknięte'
    when 0, nil
      ''
    else
      'Error !'
    end  
  end

  def can_destroy?
    status != PROPOSAL_CLOSED
  end

  def can_edit?
    status != PROPOSAL_CLOSED
  end

  private
  
    def set_initial_status_and_multi_app_identifier
      self.status = PROPOSAL_CREATED unless self.status.present?
      self.multi_app_identifier = SecureRandom.uuid unless self.multi_app_identifier.present?
    end

end
