class ProposalPolicy < ApplicationPolicy
  attr_reader :user, :model

  def initialize(user, model)
    @user = user
    @model = model
  end

  def wizard?
    (@model.creator_id == @user.id) && (user_activities.include? 'proposal:show_self') 
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

  def edit?
    update?
  end

  def edit_self?
    update_self?
  end

  def update?
    user_activities.include? 'proposal:update'
  end

  def update_self?
    user_activities.include? 'proposal:update_self'
  end

  def destroy?
    user_activities.include? 'proposal:delete'
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
        scope.all
      elsif user_activities.include? 'proposal:index_self'
        scope.where(creator_id: @user.id)
      else
        scope.where(id: -1)
      end
    end
  end
end