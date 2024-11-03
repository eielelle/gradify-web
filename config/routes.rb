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
  get "/student", to: "student/overview#index", as: :student_root

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
          get 'history', to: 'history#index', as: 'history'
          get 'versions/:id', to: 'history#versions', as: 'versions'
          get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
          post 'rollback/:id', to: 'history#rollback', as: 'rollback'
          namespace :sections do
            resources :manage, only: [:create, :edit, :update, :show, :new, :index, :destroy]
            get 'export', to: 'export#index', as: 'export'
            get 'send_exports', to: 'export#download', as: 'download'
            get 'history', to: 'history#index', as: 'history'
            get 'versions/:id', to: 'history#versions', as: 'versions'
            get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
            post 'rollback/:id', to: 'history#rollback', as: 'rollback'
          end
          namespace :students do
            resources :manage, only: [:show, :index, :create] do
              collection do
                post :unassign_selected
              end
            end
          end
          namespace :teachers do
            resources :manage, only: [:show, :index, :create] do
              collection do
                post :unassign_selected
              end
            end
          end
        end
      end

      get 'export', to: 'export#index', as: 'export'
      get 'send_exports', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
    end

    namespace :subjects do
      resources :manage, only: %i[index new create edit update destroy show]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
      get 'history', to: 'history#index', as: 'history'
      get 'versions/:id', to: 'history#versions', as: 'versions'
      get 'snapshot/:id', to: 'history#snapshot', as: 'snapshot'
      post 'rollback/:id', to: 'history#rollback', as: 'rollback'
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
      resources :manage, only: [:index, :show] do
        member do
          get 'exam_details/:exam_id', to: 'manage#exam_details', as: 'exam_details'
          get 'student_exam_overviews/:exam_id/:student_id', to: 'manage#student_exam_overviews', as: 'student_exam_overviews'
        end
      end
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

      get 'teacher/exams', to: 'teacher/exams#index', as: :api_v1_get_teacher_exams
      get 'teacher/responses', to: 'teacher/responses#index', as: :api_v1_get_teacher_responses
      post 'teacher/responses', to: 'teacher/responses#create', as: :api_v1_create_teacher_response
      get 'teacher/classes', to: 'teacher/classes#get_classes', as: :api_v1_create_teacher_classes
      get 'teacher/class/years', to: 'teacher/classes#get_school_years', as: :api_v1_create_teacher_classes_sy
      get 'teacher/class/year/sections', to: 'teacher/classes#get_sections', as: :api_v1_create_teacher_classes_sy_sections
      get 'teacher/class/subjects', to: 'teacher/classes#get_subjects', as: :api_v1_create_teacher_classes_subjects
      get 'teacher/section/students', to: 'teacher/classes#get_students', as: :api_v1_create_teacher_sections_students

    end
  end

  namespace :student do
    # /student/config
    resource :config, only: [:show, :update, :destroy], controller: 'config', as: 'config'
    patch 'change_password', to: 'config#change_password'
    get 'confirm_destroy', to: 'config#confirm_destroy'

    # /student/exams
    namespace :exams do
      resources :manage, only: [:index, :show]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
    end

    # /student/classes
    namespace :classes do
      resources :manage, only: [:index, :show]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
    end

    # /student/grades
    namespace :grades do
      resources :manage, only: [:index, :show]
      get 'export', to: 'export#index', as: 'export'
      get 'download', to: 'export#download', as: 'download'
    end

  end
  # end of new routing 
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'student/sign_in', to: 'student/sessions#create', as: :api_v1_student_sign_in
        delete 'student/sign_out', to: 'student/sessions#destroy', as: :api_v1_student_sign_out
      end

      get 'student/exams', to: 'student/exams#index', as: :api_v1_get_student_exams
    end
  end
end
