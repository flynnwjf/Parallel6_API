require_relative "../../../base_api"

module V3
  module Agreement
    module Templates
      class Update < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "template_name": "#{@template_name}",
			                  "description": "#{@description}"
                    }
                }
           }
          JSON
        end
        private def update_session
          response = RestClient.patch("https://#{@env}/v3/agreement/templates/#{@id}",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :template_name, :description

        def initialize(token, email, environment, id, type, template_name, description)
          @email = email
          @env = environment
          @token = token
          @id = id
          @type = type
          @template_name = template_name
          @description = description
        end

        def response
          @response ||= update_session
        end

      end
    end
  end
end
