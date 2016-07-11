Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'users' => "users#index"

  devise_for :users, :controllers => {:confirmations => 'confirmations', :registrations => 'registrations'}

  devise_scope :user do
    put "/confirm" => "confirmations#confirm"
    post '/sign_up' => 'registrations#create'
  end

  get 'home/index'
  root :to => 'home#index'
  mount API => '/'



  post 'api/v1/accounts/create'        => 'home#create'
  post 'api/v1/accounts/sign_in'        => 'home#create_session'
  post 'api/v1/accounts/social_sign_in' => 'home#social_sign_in'
  post 'api/v1/accounts/sign_out'       => 'home#delete_session'

  post 'api/v1/accounts/destroy'        => 'home#destroy'
  # post 'api/v1/accounts/sign_in_with_social'        => 'home#create_social_session'

end
