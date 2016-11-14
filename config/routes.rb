Rails.application.routes.draw do
  resources :questions

  authenticated :user do
    get :mentionable => 'users/mentions#mentionable'
    root :to => 'questions#index', as: :authenticated_root
  end
  root :to => 'home#index'

  resources :users , only: [:mentionable] do
    member do
      get :mentionable
    end
  end

  devise_for :users, controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions",
      omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    delete "/users/sign_out" => "devise/sessions#destroy"
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
