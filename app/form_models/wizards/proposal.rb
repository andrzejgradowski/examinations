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
      validate :unique_category_for_creator , unless: -> { category.blank? }

      private
        def unique_category_for_creator
          if ::Proposal.where(category: category, creator_id: creator_id).where.not(status: [::Proposal::PROPOSAL_CLOSED]).any? 
            errors.add(:category, " - Jest aktualnie procedowane Twoje zgłoszenie dla tej służby")
            false
          end
        end
    end

    class Step5 < Step4
      # validates :exam_id, presence: true
      # validate :category_compliance, unless: -> { exam_id.blank? } 

      # private
      #   def category_compliance
      #     unless category == exam_category
      #       errors.add(:exam_id, " - Niewłaściwa kategoria sesji egzaminacyjnej. Wybierz ponownie")
      #       false
      #     end
      #   end
    end

  end
end
