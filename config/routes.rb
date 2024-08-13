# frozen_string_literal: true

Rails.application.routes.draw do
  # devise_for :teacher_accounts
  # TODO: fix route scope later
  devise_for :student_accounts
  devise_for :admin_accounts, path: :admin, only: [:sessions]

  devise_for :teacher_accounts, path: '/api/v1/teacher', path_names: {
    sign_in: 'sign_in',
    sign_out: 'sign_out',
  },
  controllers: {
    sessions: 'api/v1/teacher/sessions',
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root "welcome#index"
  get "/admin", to: "admin/overview#index", as: :admin_account_root

  # /admin
  namespace :admin do
    # /admin/config
    resource :config, only: [:show, :update, :destroy], controller: 'admins/config', as: 'config'

    # /admin/admins
    namespace :admins do
      resources :manage, as: 'manage'
      resources :password, as: 'password', only: [:edit, :update]
      patch 'change_password', to: 'config#change_password' # config related
      get 'confirm_destroy', to: 'config#confirm_destroy'  # config related
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback' 
    end

    # /admin/teachers
    namespace :teachers do
      resources :manage, as: 'manage'
      resources :password, as: 'password', only: [:edit, :update]
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback' 
    end

    namespace :students do
      resources :manage, only: %i[index new create edit update destroy show]
      resources :password, only: [:edit, :update]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
    end
  
    namespace :sections do 
    resources :manage, only: %i[index new create edit update destroy show]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#version', as: 'version'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
    end

    # /admin/admins
    namespace :classes do
      resources :manage, as: 'manage'
      # resources :password, as: 'password', only: [:edit, :update]
      # patch 'change_password', to: 'config#change_password' # config related
      # get 'confirm_destroy', to: 'config#confirm_destroy'  # config related
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      # get 'history', to: 'history#index', as: 'history'
      # get 'versions', to: 'history#versions', as: 'versions'
      # get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      # post 'rollback/:id', to: 'history#rollback', as: 'rollback' 
    end
  end
end
