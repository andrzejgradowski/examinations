class Proposal < ApplicationRecord

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
  after_initialize :set_initial_status

  def save
    return false if invalid?
    ActiveRecord::Base.transaction do
      super
      Rails.logger.info('...........................................')
      Rails.logger.info('........./save with API..............')
      Rails.logger.info('...........................................')
      #user.create_location!(country: country, city: city)
    end
    true
  rescue ActiveRecord::StatementInvalid => e
    # Handle exception that caused the transaction to fail
    # e.message and e.cause.message can be helpful
    errors.add(:base, e.message)
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
  
    def set_initial_status
      self.status = PROPOSAL_CREATED unless self.status.present?
    end

end
