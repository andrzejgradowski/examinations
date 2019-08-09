puts " "
puts "#####  RUN - 010_role.rb  #####"

#user = CreateAdminService.new.call
#puts 'CREATED ADMIN USER: ' << user.email 
#user.log_work('create', 1)

role = CreateRoleService.new.role_admin
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.user_admin
puts 'CREATED ROLE: ' << role.name

# role = CreateRoleService.new.work_observer
# puts 'CREATED ROLE: ' << role.name
# role.log_work('create', 1)
# user.roles << role 
# puts "ADD ROLE: #{role.name}   TO USER: #{user.email}"


role = CreateRoleService.new.proposal_admin
puts 'CREATED ROLE: ' << role.name

role = CreateRoleService.new.proposal_writer
puts 'CREATED ROLE: ' << role.name


puts "#####  END OF - 010_role.rb  #####"
puts " "
