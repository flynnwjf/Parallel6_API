require_relative "../../../base_api"

module V3
  module DynamicContent
    module AttributeKeys
      class Create < BaseAPI

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
                              "id": #{type_id}
                              }
                         }
                    }
                }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/dynamic_content/attribute_keys",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :name, :display_name, :type_id

        def initialize(token, email, environment, type, type_id, name, display_name)
          @email = email
          @env = environment
          @token = token
          @type = type
          @type_id = type_id
          @name = name
          @display_name = display_name

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
