#Rails.application.config.session_store :active_record_store, :key => '_examinations_session'

Rails.application.config.session_store :cache_store, key: Rails.application.secrets.cache_store_key
