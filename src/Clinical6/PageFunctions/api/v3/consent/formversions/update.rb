require_relative "../../../base_api"

module V3
  module Consent
    module FormVersions
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "id": #{id},
            "data": {
              "type": "consent__form_versions",
              "attributes": {},
              "relationships": {
                "agreement_template": {
                  "data": {
                    "id": #{agreement_template_id},
                    "type": "agreement__templates"
                  }
                },
                "site": {
                  "data": {
                    "id": 1,
                    "type": "trials__sites"
                  }
                },
                "consent_form": {
                  "data": {
                    "id": 1,
                    "type": "consent__forms"
                  }
                },
                "language": {
                  "data": {
                    "id": 1,
                    "type": "languages"
                  }
                }
              }
            }
          }
          JSON
        end

        private def patch_update
          response = RestClient.patch("https://#{@env}/v3/consent/form_versions/#{@id}", payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id, :agreement_template_id

        def initialize(token, email, environment, id, agreement_template_id)
          @email = email
          @env = environment
          @token = token
          @id = id
          @agreement_template_id = agreement_template_id
        end

        def response
          @response ||= patch_update
        end

      end
    end
  end
end
