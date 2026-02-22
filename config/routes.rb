Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

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
