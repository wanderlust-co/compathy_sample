Rails.application.routes.draw do

  get  "sa"                 => "subapp#index"
  get  "sa/*subapp"         => "subapp#index"

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

  get "templates/*template"                                => "templates#get_tpl"

  namespace :api, {format: 'json'} do
    resources :tripnotes
    put    "tripnotes/:id/cover_photo" => "tripnotes#set_cover_photo"
    post   "tripnotes/:id/cover_photo" => "tripnotes#add_cover_photo"
    put    "tripnotes/:id/openness" => "tripnotes#set_openness"
    post   "comments" => "comments#create"
    post   "favorites" => "favorites#create"
    delete "favorites/:id" => "favorites#destroy"
    post   "likes" => "likes#create"
    delete "likes/:id" => "likes#destroy"
  end

  resources :tripnotes

  resources :user_reviews
  resources :user_photos do
    collection do
      post "with_episode"
    end
  end

  if Rails.env.development?
    get '/rails/mailer/*path' => "rails/mailers#preview"
  end
end
