Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    post 'login' => 'authentication#login'
    
    resources :uploaded_files, only: [:create, :index] do
      post :share_link, on: :member
    end

  end
  get 'share_links/:hex' => 'share_links#show'
end