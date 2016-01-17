require 'sinatra/base'
require 'json'
require 'httparty'
require './nest_device'
require './alexa_objects'

module Sinatra
  class MyApp < Sinatra::Base
    
    register Sinatra::NestDevice
  
    set :protection, :except => [:json_csrf]
    enable :inline_templates

    before do
      if request.request_method == "POST"
        @data = request.body.read
        params.merge!(JSON.parse(@data))
        @echo_request = AlexaObjects::EchoRequest.new(JSON.parse(@data)) 
        @application_id = @echo_request.application_id
      end
    end
  run!
  end
end
