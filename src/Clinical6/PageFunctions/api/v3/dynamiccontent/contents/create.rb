require_relative "../../../base_api"

module V3
  module DynamicContent
    module Contents
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "heart_rate": 120,
			                  "visibility_status": "enabled"
                    },
                    "relationships": {
                         "content_type": {
                              "data": {
                              "type": "dynamic_content__content_types",
                              "id": "#{@content_type_id}"
                              }
                         },
                        "mobile_user": {
                          "data": {
                            "type": "mobile_users",
                            "id": #{mobile_id}
                          }
                        }
                    }
                }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/dynamic_content/contents",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :content_type_id, :mobile_id

        def initialize(token, email, environment, type, content_type_id, mobile_id)
          @email = email
          @env = environment
          @token = token
          @type = type
          @content_type_id = content_type_id
          @mobile_id = mobile_id
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
