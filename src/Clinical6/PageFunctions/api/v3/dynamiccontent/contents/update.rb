require_relative "../../../base_api"

module V3
  module DynamicContent
    module Contents
      class Update < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
                        "title": "#{@title}",
			                  "heart_rate": 150,
			                  "visibility_status": "#{@visibility_status}"
                    }
                }
           }
          JSON
        end

        private def update_session
          response = RestClient.patch("https://#{@env}/v3/dynamic_content/contents/#{@id}",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :id, :title, :visibility_status

        def initialize(token, email, environment, id, type, title, visibility_status)
          @email = email
          @env = environment
          @token = token
          @type = type
          @id = id
          @title = title
          @visibility_status = visibility_status
        end

        def response
          @response ||= update_session
        end

      end
    end
  end
end
