require_relative "../../base_api"

module V3
  module Permissions
    class Update < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
           {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "scope_name": "#{scope_name}",
                        "fields": [ ],
			                  "enabled": true
                    },
                    "relationships": {
                        "user_role": {
                            "data":	{ 
			                          "id": "1", 
				                        "type": "user_roles" 
			                      }
                        },
                         "authorizable": {
                             "data": {
                                  "type": "sections",
                                  "id": "#{authorizable_id}"
                             }
                         }
                    }
                }
            }
        JSON
      end

      private def update_session
        response = RestClient.patch("https://#{@env}/v3/permissions/#{@id}",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }

        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token,  :type, :scope_name, :authorizable_id, :id

      def initialize(token, email, environment, id, type, scope_name, authorizable_id)
        @email = email
        @env = environment
        @token = token
        @type = type
        @scope_name = scope_name
        @authorizable_id = authorizable_id
        @id = id
      end

      def response
        @response ||= update_session
      end

    end
  end
end
