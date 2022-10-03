Rails.application.routes.draw do
  get 'users/info'
  post '/create-payment-intent', to: 'payment_intent#create'
  devise_for :users
  root to: "home#index"
  resources :publications, only: [:index, :show]
  namespace :admin do
    resources :publications
  end
end
