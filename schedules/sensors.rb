module Lita
  module Schedules
    class Sensors < Schedule

      cron('0,30 * * * * Asia/Tokyo', :report_status)

      def self.default_config(schedule_config)
        schedule_config.room     = nil
      end

      def report_status
        light_str, temp_str, humidity_str = fetch_status
        status = "temperature:#{temp_str}, humidity:#{humidity_str}, light:#{light_str}"

        room   = Lita.config.schedules.lights.room
        target = Struct.new(:room).new(room)
        robot.send_message(target, status)
      end

      private

      def fetch_status
        board = Dino::Board.new(Dino::TxRx.new)
        light_sensor       = Dino::Components::Sensor.new(pin: 'A0', board: board)
        temperature_sensor = Dino::Components::Sensor.new(pin: 'A2', board: board)
        humidity_sensor    = Dino::Components::Sensor.new(pin: 'A3', board: board)

        light_dataset = []
        light_sensor.when_data_received do |data|
          light_dataset << data.to_i
        end

        temp_dataset = []
        temperature_sensor.when_data_received do |data|
          temp_dataset << data.to_i
        end

        humidity_dataset = []
        humidity_sensor.when_data_received do |data|
          humidity_dataset << data.to_i
        end

        sleep 2

        light_value     = light_dataset.inject(:+).to_f / light_dataset.size
        temp_value     = temp_dataset.inject(:+).to_f / temp_dataset.size
        humidity_value  = humidity_dataset.inject(:+).to_f / humidity_dataset.size
        p humidity_dataset.inject(:+).to_f
        p humidity_dataset.size

        light_str = "%1.1f" % Math.log(light_value + 1.0)
        temp_str  = "%2.1f" % (temp_value / 1024 * 5 / 0.01)
        humidity_str  = "%2.1f" % (humidity_value / 1024 * 5 / 0.01)

        [light_str, temp_str, humidity_str]
      end
    end

    Lita.register_schedule(Sensors)
  end
end