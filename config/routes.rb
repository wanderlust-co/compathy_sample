Rails.application.routes.draw do

  get 'oauths/oauth'

  get 'oauths/callback'

  root :to => 'tripnotes#index'
  resources :user_sessions
  resources :users

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout

  post "oauth/callback" => "oauths#callback"
  get "oauth/callback" => "oauths#callback" # for use with Github, Facebook
  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  namespace :api, {format: 'json'} do
    resources :tripnotes
    put    "tripnotes/:id/cover_photo" => "tripnotes#set_cover_photo"
    post   "tripnotes/:id/cover_photo" => "tripnotes#add_cover_photo"
    put    "tripnotes/:id/openness" => "tripnotes#set_openness"

    post   "comments" => "comments#create"
  end

  resources :tripnotes

  resources :user_reviews
  resources :user_photos do
    collection do
      post "with_episode"
    end
  end
  # root 'tripnotes#index'
  # resources :tripnotes, :except => :index

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
end
