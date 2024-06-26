Rails.application.routes.draw do
  resources :events, only: [:index] do
    resources :ticket_reservations, param: :reservation_reference, only: [:new, :create, :show] do
      get :expire, on: :member
      get :cancel, on: :member
    end
    resources :orders, only: [:new, :create, :show]
  end

  # events are under the admin namespace
  namespace :admin do
    resources :events, only: [:index, :new, :create, :edit, :update, :show]
  end

  get "pages/about_us"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "events#index"
end
