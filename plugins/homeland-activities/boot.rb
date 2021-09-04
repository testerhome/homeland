$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'homeland/activities'

Homeland.register_plugin do |plugin|
  plugin.name              = 'activities'
  plugin.display_name      = '活动'
  plugin.description       = '活动'
  plugin.version           = Homeland::Activities::VERSION
  plugin.navbar_link       = true
  plugin.admin_navbar_link = true
  plugin.root_path         = '/events'
  plugin.admin_path        = '/admin/events'
end