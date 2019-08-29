class User < ApplicationRecord
  include ActionView::Helpers::UrlHelper # for link_to
  #delegate :url_helpers, to: 'Rails.application.routes'

  devise :saml_authenticatable, :trackable

  has_and_belongs_to_many :roles

  has_many :proposals, class_name: 'Proposal', primary_key: 'id', foreign_key: 'creator_id'

  has_one_attached :face_image
  has_one_attached :bank_pdf


  after_commit :set_default_role, on: :create

  def set_default_role
    role = CreateRoleService.new.proposal_writer
    self.roles << role 
  end
  
  def name
    "#{first_name} #{last_name}"
  end

  def fullname
    "#{name} (#{email})"
  end

  def name_as_link
    link_to "#{self.user_name}", "#{url_helpers.user_path(self)}"
    # "<a href=#{url_helpers.user_path(self)}>#{self.name}</a>".html_safe
  end

  def user_link_add_remove(role, has_user)
    if has_user
      "<div style='text-align: center'><button ajax-path='#{url_helpers.role_user_path(role_id: role, id: self.id)}' ajax-method='DELETE' class='btn btn-xs btn-danger glyphicon glyphicon-minus'></button></div>".html_safe
    else
      "<div style='text-align: center'><button ajax-path='#{url_helpers.role_users_path(role_id: role, id: self.id)}' ajax-method='POST' class='btn btn-xs btn-success glyphicon glyphicon-plus'></button></div>".html_safe
    end
  end

  # def self.load_saml_data attributes
  #   user = where(email: attributes['email']).first_or_create do |u|
  #     u.email = attributes['email']
  #     u.first_name = attributes['first_name']
  #     u.last_name = attributes['last_name']
  #     u.username = attributes['username']
  #   end
  #   user.save!
  #   user
  # end


  # def set_user_saml_attributes(user,attributes)
  #   attribute_map.each do |k,v|
  #     Rails.logger.info "Setting: #{v}, #{attributes[k]}"
  #     user.send "#{v}=", attributes[k]
  #   end
  # end


end
