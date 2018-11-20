require_relative "../../../base_api"

module V3
  module Agreement
    module Templates
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "template_name": "#{@template_name}",
			                  "description": "#{@template_name}",
                        "approval_required": true,
                        "permanent_link": "#{@template_name}",
                        "expiration": 26
                    }
                }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/agreement/templates",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :template_name

        def initialize(token, email, environment, type, template_name)
          @email = email
          @env = environment
          @token = token
          @type = type
          @template_name = template_name
        end

        def response
          @response ||= create_session
        end

        def id
          @id ||= JSON.parse(response).dig('data', 'id')
        end

      end
    end
  end
end
