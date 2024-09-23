# frozen_string_literal: true


# # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
# # Can be used by load balancers and uptime monitors to verify that the app is live.
# get 'up' => 'rails/health#show', as: :rails_health_check

Rails.application.routes.draw do
  devise_for :users, only: [:sessions]

  # new routing

  root "welcome#index"
  get "/admin", to: "admin/overview#index", as: :admin_root
  get "/teacher", to: "teacher/overview#index", as: :teacher_root

  namespace :admin do
    # /admin/config
    resource :config, only: [:show, :update, :destroy], controller: 'config', as: 'config'
    patch 'change_password', to: 'config#change_password' # config related
    get 'confirm_destroy', to: 'config#confirm_destroy'  # config related

    # /admin/workforce
    namespace :workforce do
      resources :manage, as: 'manage'
      resources :password, as: 'password', only: [:update]
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback' 
    end

    namespace :exams do
      resources :manage, as: 'manage'
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
    end

    namespace :students do
      resources :manage, as: 'manage'
      resources :password, only: [:update]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
      delete 'destroy_selected', to: 'manage#destroy_selected', as: 'destroy_selected'
    end

    namespace :classes do
      resources :manage, as: 'manage'
      resources :classes do
        namespace :sy do
          resources :manage, only: [:create, :edit, :update, :show, :new, :index, :destroy]
          get 'export', to: 'export#index', as: 'export'
          get 'send_exports', to: 'export#download', as: 'download'
          namespace :sections do
            resources :manage, only: [:create, :edit, :update, :show, :new, :index, :destroy]
            get 'export', to: 'export#index', as: 'export'
            get 'send_exports', to: 'export#download', as: 'download'
          end
          namespace :students do
            resources :manage, only: [:show, :index, :create]
          end
          namespace :teachers do
            resources :manage, only: [:show, :index, :create]
          end
        end
      end

      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
      delete 'destroy_selected', to: 'manage#destroy_selected', as: 'destroy_selected'
    end
    
  end

  namespace :teacher do
    # /teacher/config
    resource :config, only: [:show, :update, :destroy], controller: 'config', as: 'config'
    patch 'change_password', to: 'config#change_password' # config related
    get 'confirm_destroy', to: 'config#confirm_destroy'  # config related

    # /teacher/classes
    namespace :classes do
      resources :manage, as: 'manage', only: [:index, :show]
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
    end

    # /teacher/papers
    namespace :papers do
      resources :manage, as: 'manage', only: [:index, :show]
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
    end

    # /teacher/grades
    namespace :grades do
      resources :manage, as: 'manage'
      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
    end

    
  end
  # end of new routing  
  # # API routes with custom path and controller
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'teacher/sign_in', to: 'teacher/sessions#create', as: :api_v1_teacher_sign_in
        delete 'teacher/sign_out', to: 'teacher/sessions#destroy', as: :api_v1_teacher_sign_out
      end

      get 'classes', to: 'teacher/classes#index', as: :api_v1_get_teacher_classes
    end
  end
end

