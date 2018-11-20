require_relative "../../../base_api"

module V3
  module Consent
    module Approvers
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
          "data": {
              "attributes": {
                "first_name": "FNApprover_update",
                "last_name": "LNApprover_update",
                "email": "#{update_email}"
              }
            }
           }
          JSON
        end

        private def update_session
          response = RestClient.patch("https://#{@env}/v3/consent/approvers/#{@id}", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :token, :env, :id, :update_email

        def initialize(token, email, environment, id, update_email)
          @email = email
          @env = environment
          @token = token
          @id = id
          @update_email = update_email
        end

        def response
          @response ||= update_session
        end

      end
    end
  end
end
