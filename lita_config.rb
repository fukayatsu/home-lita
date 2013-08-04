require 'yaml'

require "lita"
require "lita-schedule"
require 'iremocon'

settings = YAML.load_file('settings.yml')
require_relative 'handlers/remote'
require_relative 'schedules/lights'

Lita.configure do |config|
  config.robot.name      = "Lita Boston"
  config.robot.log_level = :info
  config.robot.adapter   = :hipchat

  config.adapter.jid        = settings['hipchat']['jid']
  config.adapter.password   = settings['hipchat']['password']
  config.adapter.debug      = false
  config.adapter.rooms      = :all
  config.adapter.muc_domain = "conf.hipchat.com"

  config.handlers.remote.iremocon = settings['iremocon']

  config.schedules.lights.iremocon = settings['iremocon']
  config.schedules.lights.room     = settings['hipchat']['rooms']['lights']
end
