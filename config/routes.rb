Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Web auth routes
  get "login", to: "web/sessions#new", as: :login
  post "login", to: "web/sessions#create"
  delete "logout", to: "web/sessions#destroy", as: :logout
  get "register", to: "web/registrations#new", as: :register
  post "register", to: "web/registrations#create"

  # Web UI routes
  namespace :web, path: "" do
    get "dashboard", to: "dashboard#show", as: :dashboard
    root "dashboard#show"

    resources :receipts do
      member do
        post :confirm
      end
      resources :expense_lines, only: [:new, :create, :edit, :update, :destroy]
    end

    resources :business_profiles, only: [:new, :create, :edit, :update, :destroy]
    resources :accounts, only: [:new, :create, :edit, :update, :destroy]

    get "settings", to: "settings#show", as: :settings

    get "summaries", to: "summaries#index", as: :summaries

    get "exports", to: "exports#index", as: :exports
    get "exports/schedule_c_csv", to: "exports#schedule_c_csv", as: :export_schedule_c_csv
    get "exports/schedule_c_pdf", to: "exports#schedule_c_pdf", as: :export_schedule_c_pdf
    get "exports/expense_lines_csv", to: "exports#expense_lines_csv", as: :export_expense_lines_csv
  end

  namespace :api do
    namespace :v1 do
      # Auth
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"

      # Business profiles
      resources :business_profiles, only: [:index, :show, :create, :update, :destroy]

      # Accounts
      resources :accounts, only: [:index, :show, :create, :update, :destroy]

      # Receipts with nested expense lines
      resources :receipts, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :confirm
        end
        resources :expense_lines, only: [:index, :show, :create, :update, :destroy]
      end

      # Summaries
      get "summaries/by_category", to: "summaries#by_category"
      get "summaries/by_vendor", to: "summaries#by_vendor"
      get "summaries/by_account", to: "summaries#by_account"
      get "summaries/by_month", to: "summaries#by_month"
      get "summaries/schedule_c", to: "summaries#schedule_c"

      # Exports
      get "exports/schedule_c_csv", to: "exports#schedule_c_csv"
      get "exports/schedule_c_pdf", to: "exports#schedule_c_pdf"
      get "exports/expense_lines_csv", to: "exports#expense_lines_csv"

      # Inbound email webhook
      post "webhooks/inbound_email", to: "webhooks#inbound_email"
    end
  end
end
