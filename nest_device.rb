require './nest'
NEST = NestThermostat::Nest.new(email: 'your@email.here', password: 'your_password')
module Sinatra
  module NestDevice
    def self.registered(app)
      app.post '/nest' do
        content_type :json
  
        r = AlexaObjects::Response.new

        if @echo_request.launch_request? || @echo_request.intent_name == 'GetTemperature'
          r.end_session = false
          r.spoken_response = "The inside temperature is #{NEST.current_temp.to_i} degrees, and your thermostat is set to #{NEST.temperature.to_i}." +
                              " Would you like to make an adjustment."
        elsif @echo_request.intent_name == 'SetTemperature'
          target = @echo_request.slots.temperature
          r.end_session = true
          if (32..95).include?(target.to_i)
            NEST.temperature = target
            r.spoken_response = "I've set the temperature to #{target}" 
          elsif target.class == String
            target == "away" ? NEST.away = true : NEST.away = false
            if target == "away" || target == "home"
              r.spoken_response = "I've set your nest to #{target}"
            else
              r.spoken_response = "I couldn't make that adjustment. Would you like to make a different adjustment."
              r.end_session = false
            end
          end
        elsif @echo_request.intent_name == 'NoResponse'
          r.end_session = true
          r.spoken_response = "okay."
        elsif @echo_request.intent_name == 'YesResponse'
          r.end_session = false
          r.spoken_response = "To what temperature?"
        end
        r.without_card.to_json
      end
    end
  end
  register NestDevice
end
