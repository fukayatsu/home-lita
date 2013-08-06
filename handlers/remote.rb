module Lita
  module Handlers
    class Remote < Handler

      route /^remote (.+)$/, :execute, command: true

      def self.default_config(handler_config)
        handler_config.iremocon = nil
      end

      def execute(response)
        command    = response.matches[0][0]
        ray_number = ir_config['commands'][command]

        # コマンドに対応する赤外線番号がなければreturn
        response.reply('command not found') and return unless ray_number

        if send_ray(ray_number)
          response.reply("[#{command}] ok")
        else
          response.reply("[#{command}] failure")
        end
      end

      private

      def ir_config
        Lita.config.handlers.remote.iremocon
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
          puts "send_ray[#{number}] retry[#{retry_count}]"

          retry_count -= 1
          sleep 1
          retry if retry_count >= 0
        end

        false
      end
    end

    Lita.register_handler(Remote)
  end
end