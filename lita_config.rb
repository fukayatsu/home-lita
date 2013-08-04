require 'yaml'

require "lita"
require "lita-schedule"

require 'iremocon'
require 'dino'

require_relative 'handlers/remote'
require_relative 'schedules/lights'
require_relative 'schedules/sensors'

Lita.configure do |config|
  settings = YAML.load_file('settings.yml')

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
  config.schedules.sensors.room    = settings['hipchat']['rooms']['lights']
end
