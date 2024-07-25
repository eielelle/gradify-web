# frozen_string_literal: true

Rails.application.routes.draw do
  # TODO: fix route scope later
  devise_for :student_accounts
  devise_for :admin_accounts, path: :admin, only: [:sessions]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root "welcome#index"
  get "/admin", to: "admin/overview#index", as: :admin_account_root

  # get "/admin/dashboard", to: "admin_panel#index"
  namespace :admin do
    namespace :admins do
      resources :manage, as: 'manage'
      resources :password, as: 'password', only: [:edit, :update]
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      get 'rollback/:id', to: 'history#rollback', as: 'rollback' 
    end

    resources :students do
      collection do
        get 'export'
        get 'send_exports'
        get 'history'
        get 'versions'
      end
  
      member do
        get 'snapshot/:id', to: 'students#snapshot', as: 'snapshot'
        get 'rollback/:id', to: 'students#rollback', as: 'rollback' 
      end
    end
  
    resources :sections do
      get 'export', on: :collection
      get 'send_exports', on: :collection
      get 'history', on: :collection
    end
  end
end
