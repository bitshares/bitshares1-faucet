Rails.application.routes.draw do

  root 'welcome#index'
  get '/test_widget', to: 'welcome#test_widget'
  get '/refscoreboard', to: 'welcome#refscoreboard'
  get '/bitshares_login', to: 'welcome#bitshares_login'
  post '/account_registration_step2', to: 'welcome#account_registration_step2', as: 'account_registration_step2'

  #devise_for :users, ActiveAdmin::Devise.config.merge(controllers: {omniauth_callbacks: 'users/omniauth_callbacks'})
  devise_for :users, controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      confirmations: 'users/confirmations'
  }

  match 'finish_signup/:id', to: 'users#finish_signup', as: 'finish_signup', via: [:get, :patch]
  match 'user/bitshares_account', to: 'users#bitshares_account', as: 'bitshares_account', via: [:get, :post]
  get 'users/subscribe', to: 'users#subscribe'

  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', :as => :sign_out
  end

  resources :widgets do
    get 'w'
    get 'action'
    get 'get_current_user'
  end

  get 'profile', to: 'users#profile', as: 'profile'
  namespace :profile do
    resources :referral_codes, except: [:edit] do
      member do
        post 'send_mail'
        get 'fund'
      end

      collection do
        get 'referral_login'
        post 'redeem'
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :referral_codes do
        get 'redeem'
      end
    end
  end

  ActiveAdmin.routes(self)

end
