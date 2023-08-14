Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get 'users/:user_id', to: 'user#show'
  get "admin/:user_id", to: "user#list_users"
  get "is_admin/:user_id", to: "user#is_admin"
end
