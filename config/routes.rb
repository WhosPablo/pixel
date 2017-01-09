Rails.application.routes.draw do

  resources :labels
  resources :questions
  get 'auto_labels', to: 'questions#auto_labels'

  resources :comments, only: [:create, :destroy]

  unauthenticated :user do
    root 'home#front_page'
  end

  authenticated :user do
    root :to => 'home#index', as: :authenticated_root
    mount ActionCable.server => '/cable'
  end

  devise_for :users, controllers: {
      registrations: "users/registrations",
      sessions: "users/sessions",
      omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    delete "/users/sign_out" => "devise/sessions#destroy"
  end

  resources :users , only: [:show, :mentionable] do
    member do
      get :mentionable
      get :notifications
      put :clear_notifications
    end
  end

  get 'search', to: 'search#search'

  post 'commands', to: 'slack_commands#create'
  post 'slack_interactions', to: 'slack_interactions#create'


  root :to => 'home#front_page'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
