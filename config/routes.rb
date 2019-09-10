Rails.application.routes.draw do

#          new_user_session GET      /users/saml/sign_in(.:format)                       devise/saml_sessions#new
#              user_session POST     /users/saml/auth(.:format)                          devise/saml_sessions#create
#      destroy_user_session DELETE   /users/sign_out(.:format)                           devise/saml_sessions#destroy
#     metadata_user_session GET      /users/saml/metadata(.:format)                      devise/saml_sessions#metadata
# idp_sign_out_user_session GET|POST /users/saml/idp_sign_out(.:format)                  devise/saml_sessions#idp_sign_out


  devise_for :users, controllers: {
    saml_sessions: 'users/saml_sessions'
  }

  get '/netpar/exams_select2_index'
  get '/netpar/exams/:id', to: 'netpar#exam_show'
  get '/netpar/divisions_select2_index'
  get '/netpar/divisions/:id', to: 'netpar#division_show'

  scope "/:locale", locale: /#{I18n.available_locales.join("|")}/ do

    resources :uke_regulations, only: [:index]
    resources :proposals, param: :multi_app_identifier, except: [:edit, :update, :destroy] do
      patch 'update_annulled', on: :member
    end


	  get 'static_pages/home'

    root to: 'static_pages#home'
	end

  root to: redirect("/#{I18n.default_locale}", status: 302), as: :redirected_root
  # get "/*path", to: redirect("/#{I18n.default_locale}/%{path}", status: 302),
  #               constraints: { path: /(?!(#{I18n.available_locales.join("|")})\/).*/ },
  #               format: false


  namespace :api, defaults: { format: :json } do
    require 'api_constraints'
    namespace :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      get :token, controller: 'base_api'

      resources :proposals, param: :multi_app_identifier, except: [:new, :edit, :create, :destroy]

    end

    namespace :v2 do
    end
  end
end
