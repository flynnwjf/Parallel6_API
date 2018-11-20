require_relative "../../../base_api"

module V3
  module Consent
    module AdditionalSignatures
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
          "data": {
              "type": "#{type}",
              "attributes": {
                 "name": "#{name}"
               },
               "relationships": {
                  "form": {
                     "data": {
                         "id": 1,
                         "type": "consent__forms"
                      }
                  }
               }
            }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/consent/additional_signatures", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :token, :env, :type, :name

        def initialize(token, email, environment, type, name)
          @email = email
          @env = environment
          @token = token
          @type = type
          @name = name
        end

        def response
          @response ||= create_session
        end

        def id
          @id ||= JSON.parse(response.body).dig("data", "id")
        end

      end
    end
  end
end
