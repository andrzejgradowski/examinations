class Proposal < ApplicationRecord

  PROPOSAL_CREATED = 1
  PROPOSAL_IN_PROGRESS = 2
  PROPOSAL_APPROVED = 3
  PROPOSAL_PAYED = 3
  PROPOSAL_CLOSED = 4


  CATEGORY_NAME_M = "Świadectwo służby morskiej i żeglugi śródlądowej"
  CATEGORY_NAME_R = "Świadectwo służby radioamatorskiej"

  # relations
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  # validates
  validates :status, presence: true, inclusion: { in: [PROPOSAL_CREATED, PROPOSAL_IN_PROGRESS, PROPOSAL_APPROVED, PROPOSAL_PAYED, PROPOSAL_CLOSED] }
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
  after_initialize :set_status

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      super
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
    when PROPOSAL_IN_PROGRESS
      'Analiza zgłoszenia'
    when PROPOSAL_APPROVED
      'Zgłoszenie zatwierdzone'
    when PROPOSAL_APPROVED
      'Zgłoszenie opłacone'
    when PROPOSAL_CLOSED
      'Zgłoszenie zamknięte'
    when 0, nil
      ''
    else
      'Error !'
    end  
  end

  private
  
    def set_status
      self.status = PROPOSAL_CREATED unless self.status.present?
    end

end
