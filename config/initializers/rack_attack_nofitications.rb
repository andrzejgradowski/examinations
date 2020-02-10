# ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, req| 
#   if req.env['rack.attack.match_type'] == :throttle 
#     Rails.logger.info "--------------------------------------------------" 
#     Rails.logger.info "Throttled IP: #{req.ip}" 
#     Rails.logger.info "--------------------------------------------------" 
#   end 
# end

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
  req = payload[:request]

  request_headers = { "CF-RAY" => req.env["HTTP_CF_RAY"] }

  Rails.logger.info "------------------------------------------------------------------------------------" 
  Rails.logger.info "[Rack::Attack][Blocked] remote_ip: #{req.remote_ip}, start: #{start}, finish: #{finish}"
  Rails.logger.info "[Rack::Attack][Blocked] path: #{req.path}, headers: #{request_headers.inspect}"
  Rails.logger.info "------------------------------------------------------------------------------------" 

  #AdminMailer.rack_attack_notification(name, start, finish, request_id, req.remote_ip, req.path, request_headers).deliver_later
end
