require 'net/ping'

module Lita
  module Schedules
    class Lights < Schedule

      # every('10s', :ping_mobile)
      cron '*   *  * * * Asia/Tokyo',  :iremocon_keep_alive
      cron '0   8  * * * Asia/Tokyo',  :wake_up
      cron '30  8  * * * Asia/Tokyo',  :turn_out
      cron '30  10 * * * Asia/Tokyo',  :go_out
      cron '0   20 * * * Asia/Tokyo',  :back_home
      cron '0   23 * * * Asia/Tokyo',  :calm_down
      cron '25  1  * * * Asia/Tokyo',  :bed_down
      cron '30  1  * * * Asia/Tokyo',  :sleeping

      def self.default_config(schedule_config)
        schedule_config.iremocon  = nil
        schedule_config.room      = nil
        schedule_config.lights_on = nil
      end

      # def ping_mobile
      #   status = false
      #   2.times do
      #     # status = Net::Ping::External.new('10.0.1.99', nil, 1).ping?
      #     ping_script_path = File.expand_path(File.dirname(__FILE__) + '/../ping/mobile.rb')
      #     status = `/usr/local/bin/macruby #{ping_script_path}` == 'true'
      #     break if status
      #   end

      #   if Lita.config.schedules.lights.lights_on == true && status == false
      #     turn_lights_off
      #   elsif Lita.config.schedules.lights.lights_on == false && status == true
      #     turn_lights_on
      #   end

      #   Lita.config.schedules.lights.lights_on = status
      # end

      def iremocon_keep_alive
        iremocon.au
      end

      def wake_up
        # all on
        exec_command 'lights warm'
        exec_command 'heater on'
        exec_command 'pad on'
      end

      def turn_out
        exec_command 'lights max'
      end

      def go_out
        # all off
        exec_command 'lights off'
        exec_command 'heater off'
        exec_command 'pad off'
      end

      def back_home
        exec_command 'lights on'
        exec_command 'heater on'
      end

      def calm_down
        exec_command 'lights warm'
        exec_command 'pad on'
      end

      def bed_down
        exec_command 'lights min'
        exec_command 'heater off'
      end

      def sleeping
        exec_command 'lights off'
      end


    private

      def exec_command(command)
        room   = Lita.config.schedules.lights.room
        target = Struct.new(:room).new(room)

        ray_number = ir_config['commands'][command]
        if send_ray(ray_number)
          robot.send_message(target, "[#{command}] ok")
        else
          robot.send_message(target, "[#{command}] failure")
        end
      end

      def ir_config
        Lita.config.schedules.lights.iremocon
      end

      def iremocon
        Lita.config.iremocon ||= Iremocon.new(ir_config['address'])
      end

      def send_ray(number, retry_count: 3)
        begin
          iremocon.is(number) # IR_send
          return true
        rescue Errno::EPIPE
          # 接続を初期化
          Lita.config.iremocon = nil

          retry_count -= 1
          sleep 1
          retry if retry_count >= 0
        end

        false
      end
    end

    Lita.register_schedule(Lights)
  end
end