module Lita
  module Schedules
    class Lights < Schedule

      cron('* * * * * Asia/Tokyo', :iremocon_keep_alive)
      cron('0 8 * * * Asia/Tokyo', :turn_lights_on)
      cron('0 1 * * * Asia/Tokyo', :turn_lights_off)

      def self.default_config(schedule_config)
        schedule_config.iremocon = nil
        schedule_config.room     = nil
      end

      def iremocon_keep_alive
        iremocon.au
      end

      def turn_lights_on
        room   = Lita.config.schedules.lights.room
        target = Struct.new(:room).new(room)
        robot.send_message(target, 'good morning!')

        command = 'lights on'
        ray_number = ir_config['commands'][command]
        if send_ray(ray_number)
          robot.send_message(target, "[#{command}] ok")
        else
          robot.send_message(target, "[#{command}] failure")
        end
      end

      def turn_lights_off
        room   = Lita.config.schedules.lights.room
        target = Struct.new(:room).new(room)
        robot.send_message(target, 'good night!')

        command = 'lights off'
        ray_number = ir_config['commands'][command]
        if send_ray(ray_number)
          robot.send_message(target, "[#{command}] ok")
        else
          robot.send_message(target, "[#{command}] failure")
        end
      end

      private

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