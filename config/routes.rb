Rails.application.routes.draw do
  # Render / load balancer health checks
  get "/up", to: proc { [200, { "content-type" => "text/plain" }, ["OK"]] }
  root to: proc { [200, { "content-type" => "application/json" }, ['{"status":"ok"}']] }

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
