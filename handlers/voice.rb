module Lita
  module Handlers
    class Voice < Handler
      route /^say (.+)/, :speak, command: true
      def speak(response)
        say response.matches[0][0]
      end
    end
    Lita.register_handler(Voice)
  end
end
