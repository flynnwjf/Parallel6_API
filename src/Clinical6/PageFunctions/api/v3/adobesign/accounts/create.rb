require_relative "../../../base_api"

module V3
  module AdobeSign
    module Accounts
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "email": "#{@adobe_email}",
                         "first_name": "FNTest",
                         	"last_name": "LNTest",
    	                    "company_name": "P6"
                    }
                }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/adobe_sign/accounts",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :token, :type, :adobe_email

        def initialize(token, email, environment, type, adobe_email)
          @email = email
          @env = environment
          @token = token
          @type = type
          @adobe_email = adobe_email
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
