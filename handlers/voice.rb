module Lita
  module Handlers
    class Voice < Handler
      route /^say (.+)/,    :speak,    command: true
      route /^\[(.+)？\]$/, :question, command: false

      def question(response)
        q = response.matches[0][0]
        case q
        when '今何時'
          say "#{Time.now.strftime('%H:%M')}です。"
        when '今日の天気は'
          shibuya = WeatherJp.get :shibuya
          say shibuya.today.to_s
        end
      end

      def speak(response)
        say response.matches[0][0]
      end
    end
    Lita.register_handler(Voice)
  end
end
