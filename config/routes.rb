Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"
      get "auth/me", to: "auth#me"

      resources :expense_reports do
        member do
          post :submit
          post :approve
          post :reject
        end
      end

      get "dashboard", to: "dashboard#show"
    end
  end
end
