Rails.application.routes.draw do
  unless Rails.env.production?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # 認証
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"
      post "auth/refresh", to: "auth#refresh"
      post "auth/verify_email", to: "auth#verify_email"
      post "auth/resend_verification", to: "auth#resend_verification"

      # ユーザー
      get "users/me", to: "users#me"
      patch "users/me", to: "users#update_me"
      resources :users, only: [ :index, :show ]

      # コース
      resources :courses do
        member do
          post :submit_for_review
          post :approve
          post :reject
          post :unpublish
          post :archive
          post :unarchive
        end

        # セクション（ネスト）
        resources :sections, only: [ :index, :create ]

        # 受講登録（ネスト）
        resources :enrollments, only: [ :create ]

        # レビュー（ネスト）
        resources :reviews, only: [ :index, :create ]
      end

      # レビュー（非ネスト: update, destroy）
      resources :reviews, only: [ :update, :destroy ]

      # セクション（非ネスト: update, destroy）
      resources :sections, only: [ :update, :destroy ] do
        # レッスン（ネスト）
        resources :lessons, only: [ :create ]
      end

      # レッスン（非ネスト: show, update, destroy）
      resources :lessons, only: [ :show, :update, :destroy ] do
        # レッスン進捗
        post :progress, to: "lesson_progresses#create", on: :member
      end

      # 受講登録
      resources :enrollments, only: [ :index, :show ] do
        member do
          post :activate
          post :suspend
          post :resume
        end
        get :progress, on: :member
      end

      # 修了証
      resources :certificates, only: [ :index ], param: :certificate_number
      get "certificates/:certificate_number", to: "certificates#show", as: :certificate

      # 通知
      resources :notifications, only: [ :index, :update ]
      post "notifications/read_all", to: "notifications#read_all"

      # 管理者向け
      namespace :admin do
        get "dashboard", to: "dashboard#show"
        get "courses", to: "dashboard#courses"
        get "courses/pending_review", to: "dashboard#pending_review"
      end
    end
  end
end
