module Wizards
  module Proposal
    STEPS = %w(step1 step2 step3 step4 step5).freeze

    class Base
      include ActiveModel::Model
  extend ActiveModel::Translation

      attr_accessor :proposal, :all_is_ok

      delegate *::Proposal.attribute_names.map { |attr| [attr, "#{attr}="] }.flatten, to: :proposal

      def initialize(proposal_attributes)
        @proposal = ::Proposal.new(proposal_attributes)
      end

    end

    class Step1 < Base
      validates :email, presence: true, format: { with: /@/ }
      validates :name, presence: true, length: { in: 1..160 } 
      validates :given_names, presence: true, length: { in: 1..50 }
      validates :birth_place, presence: true, length: { in: 1..50 }
      validates :birth_date, presence: true
      validate :check_pesel, unless: -> { pesel.blank? }
      validate :check_birth_date, unless: -> { pesel.blank? }

      private
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
    end

    class Step2 < Step1
      validates :address_postal_code, presence: true, length: { in: 6..10 }
      validates :address_city, presence: true, length: { in: 1..50 }
      validates :address_house, presence: true, length: { in: 1..10 }
    end

    class Step3 < Step2
      validates :c_address_postal_code, presence: true, length: { in: 6..10 }
      validates :c_address_city, presence: true, length: { in: 1..50 }
      validates :c_address_house, presence: true, length: { in: 1..10 }
    end

    class Step4 < Step3
      validates :category, presence: true, inclusion: { in: %w(M R) } 
      validates :exam_id, presence: true
      validates :division_id, presence: true
      validate :unique_category_for_creator, unless: -> { category.blank? }
      validate :check_min_years_old, unless: -> { division_id.blank? }

      private
        def unique_category_for_creator
          if ::Proposal.where(category: category, creator_id: creator_id).where.not(status: [::Proposal::PROPOSAL_CLOSED]).any? 
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
    end

    class Step5 < Step4
      validates :exam_fee_id, presence: true
      validates :exam_fee_price, presence: true
    end

  end
end
