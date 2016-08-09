Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'users' => "users#index"

  get 'sales/:id/schedule_setup' => "sales#schedule_setup", as: :schedule_setup

  resources :sellers do
    resources :time_schedules
    resources :weekly_schedules
    resources :monthly_schedules
  end

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
