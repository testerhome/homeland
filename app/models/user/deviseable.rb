# frozen_string_literal: true

class User
  # Omniauth 认证函数
  module Deviseable
    extend ActiveSupport::Concern

    included do
      attr_accessor :omniauth_provider, :omniauth_uid

      devise :database_authenticatable, :registerable, :recoverable, :lockable,
         :rememberable, :trackable, :validatable, :omniauthable

      after_create :bind_omniauth_on_create
    end

    def password_required?
      (authorizations.empty? || !password.blank?) && super
    end

    # Override Devise to send mails with async
    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end

    def bind?(provider)
      authorizations.collect(&:provider).include?(provider.to_s)
    end

    def bind_service(response)
      provider = response["provider"]
      uid      = response["uid"].to_s

      authorizations.create(provider: provider, uid: uid)
    end

    def just_new_from_github?
      email.include? "@example.com"
    end

    def bind_omniauth_on_create
      if self.omniauth_provider
        Authorization.find_or_create_by!(provider: self.omniauth_provider, uid: self.omniauth_uid, user_id: self.id)
      end
    end

    # User who was logined with omniauth but not bind user info (email and password)
    def legacy_omniauth_logined?
      self.email.include?("@example.com")
    end

    module ClassMethods
      # Use Omniauth callback info to create and bind user
      def find_or_create_by_omniauth(omniauth_auth)
        Authorization.find_user_by_provider(omniauth_auth["provider"], omniauth_auth["uid"])
      end

      def new_from_provider_data(provider, uid, data)
        User.new do |user|
          user.email =
            if data["email"].present? && !User.where(email: data["email"]).exists?
              data["email"]
            else
              "#{provider}+#{uid}@example.com"
            end

          user.name  = data["name"]
          user.login = Homeland::Username.sanitize(data["nickname"])

          if provider == "github"
            user.github = data["nickname"]
          end

          if user.login.blank?
            user.login = "u#{Time.now.to_i}"
          end

          if User.where(login: user.login).exists?
            user.login = "#{user.github}-github" # TODO: possibly duplicated user login here. What should we do?
          end

          user.password = Devise.friendly_token[0, 20]
          user.location = data["location"]
          user.tagline  = data["description"]
        end
      end

      %w[github wechat developer].each do |provider|
        define_method "find_for_#{provider}" do |response|
          uid  = response["uid"].to_s
          data = response["info"]

          Authorization.find_by(provider: provider, uid: uid).try(:user)
        end
      end

      def save_by_provider(user, provider, response)
        user.save

        return user if provider.nil?

        uid  = response["uid"].to_s
        data = response["info"]
        Authorization.find_or_create_by(provider: provider, uid: uid, user_id: user.id)

        if %w[developer wechat].include?(provider)
          user.update(remote_avatar_url: data["headimgurl"])
        end
      end

      def new_for_github(response)
        uid  = response["uid"].to_s
        data = response["info"]
        provider = response["provider"]

        User.new do |user|
          user.email =
            if data["email"].present? && !User.where(email: data["email"]).exists?
              data["email"]
            else
              "#{provider}+#{uid}@example.com"
            end

          user.name  = data["name"]
          user.login = Homeland::Username.sanitize(data["nickname"])
          user.github = data["nickname"]

          if user.login.blank?
            user.login = "u#{Time.now.to_i}"
          end
        end
      end

      def new_for_developer(response)
        # new_for_github(response)
        new_for_wechat(response)
      end

      def new_for_wechat(response)
        uid  = response["uid"].to_s
        data = response["info"]
        provider = response["provider"]

        User.new do |user|
          user.email = "#{provider}+#{uid}@example.com"
          user.login = "u#{Time.now.to_i}"
          user.name = data["nickname"]
          user.location = "#{data["city"]}"
        end
      end
    end
  end
end
