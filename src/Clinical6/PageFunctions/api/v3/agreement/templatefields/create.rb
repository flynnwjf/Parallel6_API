require_relative "../../../base_api"

module V3
  module Agreement
    module TemplateFields
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {  
	             "data": {
		                "attributes": {
                        "label": "label_one",
                        "field_name": "#{@field_name}",
                        "required": "true",
                        "default_value": "template_name",
                        "attribute_name": "",
                        "signer_index": "1",
                        "source_type": "mobile_user",
                        "is_captured_value": "true"
                    },
                    "relationships":{
                        "agreement_template": {
                            "data":{
                                "id": "1",
                                "type": "agreement__template"
                             }
                        }
                    }
                }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/agreement/template_fields",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type

        def initialize(token, email, environment, field_name)
          @email = email
          @env = environment
          @token = token
          @field_name = field_name
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
