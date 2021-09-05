module Homeland
  module Activities
    class Engine < ::Rails::Engine
      isolate_namespace Homeland::Activities

      # initializer 'webpacker.proxy' do |app|
      #   insert_middleware = Homeland::Activities.webpacker.config.dev_server.present? rescue nil
      #   next unless insert_middleware

      #   app.middleware.insert_before(
      #     0, Webpacker::DevServerProxy, # 'Webpacker::DevServerProxy' if Rails version < 5
      #     ssl_verify_none: true,
      #     webpacker: Homeland::Activities.webpacker
      #   )

      #   app.middleware.insert_before(
      #     0, Rack::Static,
      #     urls: ['/events-packs'], root: Homeland::Activities.root.join('public').to_s
      #   )
      # end

      initializer "homeland.site.migrate" do |app|
        migrate_paths = [File.expand_path("../../../db/migrate", __dir__)]

        # Execute Migrations on engine load.
        ActiveRecord::Migrator.migrations_paths += migrate_paths
        begin
          ActiveRecord::Tasks::DatabaseTasks.migrate
        rescue ActiveRecord::NoDatabaseError
        end
      end

      initializer 'homeland.activites.init' do |app|
        # User.include Homeland::Press::UserMixin

        # next unless Setting.has_module?(:foo)
        # # 注册 Homeland Plugin
        # Homeland.register_plugin do |plugin|
        #   # 插件名称，应用 Ruby 的变量命名风格，例如 foo_bar
        #   plugin.name = 'activity'
        #   # 插件的名称用于显示
        #   plugin.display_name = '活动'
        #   # 版本号
        #   plugin.version = Homeland::Activities::VERSION
        #   plugin.description = '..'
        #   # 是否在主导航栏显示链接
        #   plugin.navbar_link = true
        #   # 是否在用户菜单显示链接
        #   # plugin.user_menu_link = true
        #   # 是否在管理界面的导航显示链接，需要额外配置 plugin.admin_path
        #   plugin.admin_navbar_link = true
        #   # 应用的根路径，用于生成链接
        #   plugin.root_path = "/events"
        #   # 应用的管理后台路径
        #   plugin.admin_path = "/admin/events"
        # end

        app.routes.prepend do
          mount Homeland::Activities::Engine => '/'
        end
      end
    end
  end
end
