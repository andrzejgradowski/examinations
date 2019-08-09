class CreateRoleService
  # roles
  # def work_observer
  #   role = Role.find_or_create_by!(name: "Obserwator Działań") do |role|
  #     role.activities += %w(all:work role:work user:work customer:work)
  #     role.note = "Rola służy do obserwowania historii wpisów, działań. \r\n (Przypisz tylko Administratorom systemu oraz Koordynatorom POPC)"
  #     role.save!
  #   end
  # end

  def role_admin
    role = Role.find_or_create_by!(name: "Administrator Ról Systemowych") do |role|
      role.activities += %w(role:index role:show role:create role:update role:delete role:work)
      role.note = "Rola służy do tworzenia, modyfikowania Ról. \r\n (Przypisz tylko zaawansowanym Administratorom systemu)"
      role.save!
    end
  end 
  # users
  def user_admin
    role = Role.find_or_create_by!(name: "Administrator Użytkowników") do |role|
      role.activities += %w(user:index user:show user:create user:update user:delete role:add_remove_role_user user:work)
      role.note = "Rola służy do zarządzania Użytkownikami i przypisywania im Ról Systemowych. \r\n (Przypisz tylko zaawansowanym Administratorom systemu)"
      role.save!
    end
  end
  # proposals
  def proposal_admin
    role = Role.find_or_create_by!(name: "Administrator Zgłoszeń") do |role|
      role.activities += %w(proposal:index proposal:show proposal:create proposal:update proposal:delete proposal:work)
      role.note = "Rola służy do zarządzania Zgłoszeniami. \r\n (Przypisz tylko zaawansowanym Administratorom systemu)"
      role.save!
    end
  end
  def proposal_writer
    role = Role.find_or_create_by!(name: "Wypełniający Zgłoszenia") do |role|
      role.activities += %w(proposal:index_self proposal:show_self proposal:create_self proposal:update_self proposal:delete_self)
      role.note = "Rola pozwala wypełniać Zgłoszenia. \r\n (Przypisz Użytkownikom, którzy mają wypełnić ankietę)"
      role.save!
    end
  end

end
