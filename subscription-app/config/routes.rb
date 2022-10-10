Rails.application.routes.draw do
  root to: "home#index"

  # User self management
  get 'users/info'
  get 'users/charge'
  get 'users/manage'

  # Stripe
  post '/create-checkout-session', to: 'checkout_session#create'
  post '/create-portal-session', to: 'checkout_session#create_portal_session'

  # User authentication
  devise_for :users

  # Publications
  resources :publications, only: [:index, :show]

  # Admin
  namespace :admin do
    resources :publications
  end
end
