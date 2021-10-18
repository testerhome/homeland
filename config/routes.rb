# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  use_doorkeeper do
    controllers applications: "oauth/applications",
                authorized_applications: "oauth/authorized_applications"
  end

  resources :comments
  resources :devices
  resources :teams do
    member do
      get "requestjoin"
    end
  end

  if Setting.has_module?(:home)
    root to: "home#index"
  else
    root to: "topics#index"
  end
  match "/uploads/:path(![large|lg|md|sm|xs])", to: "home#uploads", via: :get, constraints: {
    path: /[\w\d\.\/\-]+/i
  }
  get "status", to: "home#status"

  devise_for :users, path: "account", controllers: {
    registrations: "users/registrations",
    confirmations: "users/confirmations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resource :setting do
    member do
      get :account
      get :password
      get :profile
      get :reward
      get :credits
    end
  end

  # SSO
  namespace :auth do
    resource :sso, controller: "sso" do
      collection do
        get :login
        get :provider
      end
    end
  end

  delete "setting/auth/:provider", to: "settings#auth_unbind", as: "auth_unbind_setting"

  resources :nodes do
    member do
      post :block
      post :unblock
    end
  end

  get "topics/node:id", to: "topics#node", as: "node_topics"
  get "topics/node:id/feed", to: "topics#node_feed", as: "feed_node_topics", defaults: { format: "xml" }

  resources :topics do
    member do
      post :favorite
      delete :unfavorite
      post :follow
      delete :unfollow
      post :action
      get :append
      # ban popup window
      get :ban
      get :show_wechat
      get :raw_markdown
      post :read
    end

    collection do
      get :no_reply
      get :popular
      get :last
      get :last_reply
      get :banned
      get :excellent
      get :favorites
      get :feed, defaults: { format: "xml" }
      post :preview
    end

    resources :replies do
      member do
        get :reply_to
        post :reply_suggest
        post :reply_unsuggest
      end
    end
  end

  resources :photos
  resources :likes
  resources :column_channels
  resources :bugs
  resources :ads
  resources :opencourses
  resources :questions
  resources :tip_offs
  resources :invite_codes
  resources :credits

  get "/search", to: "search#index", as: "search"
  get "/search/users", to: "search#users", as: "search_users"
  get "certify", to: "certify#index"
  post "certify/answer", to: "certify#answer", as: :certify_answer

  namespace :admin do
    root to: "dashboards#index", as: "root"
    resource :dashboards do
      collection do
        post :reboot
      end
    end
    resources :credit_products do
      collection do
        get :add_variant
      end
    end

    resources :credit_settings do
      collection do
        post :sync_tech_node_ids
      end
    end
    resources :site_configs
    resources :replies
    resource :column_channels
    resources :topics do
      member do
        post :suggest
        post :unsuggest
        post :undestroy
      end
    end
    resources :nodes
    resources :columns do
      member do
        get :ban
        post :block
        post :unban
      end
    end
    resources :sections
    resources :articles
    resources :users, constraints: { id: /[#{User::LOGIN_FORMAT}]*/ } do
      member do
        delete :clean
        put :assign_nodes
        get :edit_assign_nodes
      end
      collection do
        get :ip_status
      end
    end
    post "/users/delete_users_from_ip", to: "users#delete_users_from_ip", as: "delete_users_from_ip"
    post "/users/send_message", to: "users#send_sms", as: "send_sms"
    resources :photos
    resources :admin_photos
    resources :comments
    resources :locations
    resources :applications
    resources :stats
    resources :tip_offs
    resources :plugins
    resources :invite_codes
  end

  get "api", to: "home#api", as: "api"
  get "markdown", to: "home#markdown", as: "markdown"

  namespace :api do
    namespace :v3 do
      get "hello", to: "root#hello"
      get "/bug_search", to: "bug_search#index", as: "bug_search"

      resource :devices
      resources :ads
      resource :likes
      resources :nodes
      resources :photos
      resources :notifications do
        collection do
          post :read
          get :unread_count
          delete :all
        end
      end
      resources :topics do
        member do
          post :update
          get :replies
          post :replies
          post :follow
          post :unfollow
          post :favorite
          post :unfavorite
          post :ban
          post :action
        end
      end
      resources :replies do
        member do
          post :update
        end
      end
      resources :users do
        collection do
          get :me
        end
        member do
          get :topics
          get :columns
          get :replies
          get :favorites
          get :followers
          get :following
          get :blocked
          post :follow
          post :unfollow
          post :block
          post :unblock
        end
      end

      match "*path", to: "root#not_found", via: :all
    end
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: "sidekiq"
    mount PgHero::Engine, at: "pghero"
    mount ExceptionTrack::Engine, at: "exception-track"
  end

  resources :columns do
    resources :articles
    member do
      post :follow
      delete :unfollow
      post :block
      post :unblock
    end
  end

  # TODO: Be similar to topic, can we refactor it?
  resources :articles do
    member do
      post :favorite
      delete :unfavorite
      post :follow
      delete :unfollow
      get :ban
      get :append
      get :down
      post :action
      get :show_wechat
    end

    resources :replies do
      member do
        get :reply_to
        post :reply_suggest
        post :reply_unsuggest
      end
    end
  end

  resource :github_statistics do
    get :index
  end

  mount Notifications::Engine, at: "notifications"

  # WARRING! 请保持 User 的 routes 在所有路由的最后，以便于可以让用户名在根目录下面使用，而又不影响到其他的 routes
  # 比如 http://localhost:3000/huacnlee
  get "users/city/:id", to: "users#city", as: "location_users"
  get "users", to: "users#index", as: "users"

  post "/people/join/:user_id", to: "team_users#join", as: "join"
  get "/:user_id/people/accept_all", to: "team_users#accept_all_join", as: "accept_all"
  constraints(id: /[#{User::LOGIN_FORMAT}]*/) do
    resources :users, path: "", as: "users" do
      member do
        # User only
        get :topics
        get :replies
        get :columns
        get :favorites
        get :blocked
        post :block
        post :unblock
        post :follow
        post :unfollow
        get :followers
        get :following
        get :calendar
        get :reward
        get :drafts
        get :tip_offs
      end

      resources :team_users, path: "people" do
        member do
          post :accept
          post :accept_join
          post :reject
          post :reject_join
          get :show_approve
          get :edit_user
          patch :update_user
        end
      end
    end
  end

  match "*path", to: "home#error_404", via: :all
end
