# Be sure to restart your server when you modify this file.
#Rails.application.config.session_store :active_record_store, :key => '_pola_session'

Rails.application.config.session_store :redis_store, {
  servers: [
    { host: Rails.application.secrets.redis_host, port: 6379, db: 0 },
  ],
  expire_after: 60.minutes,
  key: '_examinations_session'
}
