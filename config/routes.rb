Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root route
  root "pages#home"

  # Static pages
  get "about", to: "pages#about"
  get "services", to: "pages#services"
  get "contact", to: "pages#contact"
  post "contact", to: "pages#send_contact"

  # User authentication
  get "signup", to: "users#new"
  post "signup", to: "users#create"
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # User profile
  get "profile", to: "users#profile"
  get "profile/edit", to: "users#edit"
  patch "profile", to: "users#update"

  # Appointments
  resources :appointments

  # Book appointment shortcut
  get "book", to: "appointments#new"

  # Forum
  resources :forum_topics do
    resources :forum_posts, only: [ :create, :show, :edit, :update, :destroy ]
    member do
      post :generate_ai_topic
    end
  end
  get "forum", to: "forum_topics#index"

  # Admin
  namespace :admin do
    get "dashboard", to: "admin#dashboard"
    get "facebook_settings", to: "admin#facebook_settings"
    post "test_facebook", to: "admin#test_facebook"
  end
end
