Rails.application.routes.draw do
  get 'users/info'
  get 'users/charge'
  post '/create-checkout-session', to: 'checkout_session#create'
  devise_for :users
  root to: "home#index"
  resources :publications, only: [:index, :show]
  namespace :admin do
    resources :publications
  end
end
