Rails.application.routes.draw do
  root "posts#index"

  resources :posts do
    collection do
      get :manage
    end
  end

  get "check-updates", to: "posts#check_updates"
end
