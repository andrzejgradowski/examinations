class CreateAdminService
  def call
    user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
        user.name = Rails.application.secrets.admin_name
        user.note = 'Wbudowane konto Administratora Głównego'
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
        user.department_id = 1
      end
  end

  def call_simple(email, name, pass, department)
    user = User.find_or_create_by!(email: "#{email}".downcase) do |user|
        user.name = "#{name}"
        user.password = "#{pass}"
        user.password_confirmation = "#{pass}"
        user.department = Department.find_by(short: department)
      end
  end

end
