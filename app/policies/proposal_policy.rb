class ProposalPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def index?
    user_activities.include? 'proposal:index'
  end

  def index_self?
    user_activities.include? 'proposal:index_self'
  end

  def show?
    user_activities.include? 'proposal:show'
  end

  def show_self?
    (@model.creator_id == @user.id) && (user_activities.include? 'proposal:show_self') 
  end

  def new?
    create?
  end

  def new_self?
    create_self?
  end

  def create?
    user_activities.include? 'proposal:create'
  end

  def create_self?
    user_activities.include? 'proposal:create_self'
  end


  def annulled_self?
    (@model.creator_id == @user.id) && @model.can_annulled? && (user_activities.include? 'proposal:update_self')
  end

  def destroy_self?
    user_activities.include? 'proposal:delete_self'
  end

  # def work?
  #   user_activities.include? 'proposal:work'
  # end

  class Scope < Scope
    def resolve
      if user_activities.include? 'proposal:index'
        scope.where(confirm_that_the_data_is_correct: true).all
      elsif user_activities.include? 'proposal:index_self'
        scope.where(creator_id: @user.id, confirm_that_the_data_is_correct: true)
      else
        scope.where(id: -1)
      end
    end
  end
end