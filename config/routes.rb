Rails.application.routes.draw do
  resources :questions

  authenticated :user do
    root :to => 'questions#index', as: :authenticated_root
  end
  root :to => 'home#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    delete "/users/sign_out" => "devise/sessions#destroy"
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
