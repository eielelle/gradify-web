# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :student_accounts
  # TODO: fix route scope later
  devise_for :admin_accounts, path: :admin #, only: [:sessions]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # get "/admin/dashboard", to: "admin_panel#index"
  namespace :admin do
    resources :overview, only: [:index]
    resources :admins do
      get 'export', on: :collection
      get 'send_exports', on: :collection
      get 'history', on: :collection
    end
    resources :students do
      get 'export', on: :collection
      get 'send_exports', on: :collection
      get 'history', on: :collection
    end
  end
end
