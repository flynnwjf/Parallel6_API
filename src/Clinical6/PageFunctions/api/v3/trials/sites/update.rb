require_relative "../../../base_api"

module V3
  module Trials
    module Sites
      class Update < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                 "name": "#{@name}"
                     }
                   
                }   
           }
          JSON
        end

        private def update_session
          response = RestClient.patch("https://#{@env}/v3/trials/sites/#{@id}",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :env, :token, :type, :name, :id

        def initialize(token, email, environment, type, name, id)
          @email = email
          @env = environment
          @token = token
          @type = type
          @name = name
          @id = id
        end

        def response
          @response ||= update_session
        end

      end
    end
  end
end
