class Role < ApplicationRecord
  include ActionView::Helpers::UrlHelper # for link_to
  #delegate :url_helpers, to: 'Rails.application.routes'

  # relations
  has_and_belongs_to_many :users

  # validates
  validates :name, presence: true,
                    length: { in: 1..100 },
                    uniqueness: { case_sensitive: false }

  def fullname
    "#{name}"
  end


  def name_as_link
    link_to "#{self.name}", "#{url_helpers.role_path(self)}"
    # "<a href=#{url_helpers.role_path(self)}>#{self.name}</a>".html_safe
  end


  def role_link_add_remove(user, has_role)
    if has_role
      "<div style='text-align: center'><button ajax-path='#{url_helpers.role_user_path(role_id: self.id, id: user)}' ajax-method='DELETE' class='btn btn-xs btn-danger glyphicon glyphicon-minus'></button></div>".html_safe
    else
      "<div style='text-align: center'><button ajax-path='#{url_helpers.role_users_path(role_id: self.id, id: user)}' ajax-method='POST' class='btn btn-xs btn-success glyphicon glyphicon-plus'></button></div>".html_safe
    end
  end

end
