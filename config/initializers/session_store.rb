#Rails.application.config.session_store :active_record_store, :key => '_examinations_session'

# Rails.application.config.session_store :redis_store, {
#   servers: [
#     { host: Rails.application.secrets.redis_host, port: 6379, db: 0 },
#   ],
#   expire_after: 60.minutes,
#   key: '_examinations_session'
# }

Rails.application.config.session_store :cache_store, key: '_examinations_session'

# Rails.application.config.session_store :cache_store, {
# 			key: '_examinations_redis_session',
#       driver: :hiredis, 
#       url: 'dupa', #Rails.application.secrets.redis_url,     
#       connect_timeout: 30,  # Defaults to 20 seconds
#       read_timeout:    1.0, # Defaults to 1 second
#       write_timeout:   1.0, # Defaults to 1 second
     
#       error_handler: -> (method:, returning:, exception:) {
#         # Report errors to Sentry as warnings
#         Raven.capture_exception exception, level: 'warning',
#           tags: { method: method, returning: returning }
#       }
#     }
