require_relative "../../../base_api"

module V3
  module DynamicContent
    module AttributeKeys
      class Update < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "name": "#{@name}",
                        "display_name": "#{@display_name}",    
			                  "required": true,
                        "attribute_type": "string",
                        "status": "enabled"
                    },
                    "relationships": {
                         "content_type": {
                              "data": {
                              "type": "dynamic_content__content_types",
                              "id": 1
                              }
                         }
                    }
                }
           }
          JSON
        end

        private def update_session
          response = RestClient.patch("https://#{@env}/v3/dynamic_content/attribute_keys/#{@id}",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :token,  :environment, :id, :type, :name, :display_name

        def initialize(token, email, environment, id, type, name, display_name)
          @email = email
          @env = environment
          @token = token
          @id = id
          @type = type
          @name = name
          @display_name = display_name
        end

        def response
          @response ||= update_session
        end

      end
    end
  end
end
