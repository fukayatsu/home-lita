module Lita
  module Schedules
    class Sensors < Schedule

      cron('*/10 * * * * Asia/Tokyo', :report_status)

      def self.default_config(schedule_config)
        schedule_config.room     = nil
      end

      def report_status
        temperature_str = fetch_temperature
        lights_str      = fetch_lights
        humidity_str    = fetch_humidity

        status = "[気温]#{temperature_str}℃   [湿度]#{humidity_str}  [明るさ]#{lights_str}"

        room   = Lita.config.schedules.lights.room
        target = Struct.new(:room).new(room)
        robot.send_message(target, status)
      end

      private

      def fetch_temperature
        @board ||= Dino::Board.new(Dino::TxRx.new)
        temperature_sensor = Dino::Components::Sensor.new(pin: 'A2', board: @board)

        temp_dataset = []
        temperature_sensor.when_data_received do |data|
          temp_dataset << data.to_i
        end
        sleep 1

        temp_value = temp_dataset.inject(:+).to_f / temp_dataset.size
        temp_str   = "%2.1f" % (temp_value / 1024 * 5 / 0.01)
      end

      def fetch_lights
        @board ||= Dino::Board.new(Dino::TxRx.new)
        light_sensor       = Dino::Components::Sensor.new(pin: 'A0', board: @board)

        light_dataset = []
        light_sensor.when_data_received do |data|
          light_dataset << data.to_i
        end
        sleep 1

        light_value = light_dataset.inject(:+).to_f    / light_dataset.size
        light_str   = "%1.1f" % Math.log(light_value + 1.0)
      end

      def fetch_humidity
        @board ||= Dino::Board.new(Dino::TxRx.new)
        humidity_sensor    = Dino::Components::Sensor.new(pin: 'A3', board: @board)

        humidity_dataset = []
        humidity_sensor.when_data_received do |data|
          humidity_dataset << data.to_i
        end
        sleep 1

        humidity_value  = humidity_dataset.inject(:+).to_f / humidity_dataset.size
        humidity_str  = "%2.1f" % (humidity_value / 1024 * 5 / 0.01)
      end
    end

    Lita.register_schedule(Sensors)
  end
end