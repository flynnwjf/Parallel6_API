require_relative "../../../base_api"

module V3
  module Consent
    module FormVersions
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
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
                    "id": #{site_id},
                    "type": "trials__sites"
                  }
                },
                "consent_form": {
                  "data": {
                    "id": #{form_id},
                    "type": "consent__forms"
                  }
                },
                "language": {
                  "data": {
                    "id": #{language_id},
                    "type": "languages"
                  }
                }
              }
            }
          }
          JSON
        end

        private def create
          response = RestClient.post("https://#{@env}/v3/consent/form_versions", payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :agreement_template_id, :site_id, :form_id, :language_id

        def initialize(token, email, environment, agreement_template_id, site_id, form_id, language_id)
          @email = email
          @env = environment
          @token = token
          @agreement_template_id = agreement_template_id
          @site_id = site_id
          @form_id = form_id
          @language_id = language_id
        end

        def response
          @response ||= create
        end

        def id
          @id ||= JSON.parse(response.body).dig('data', 'id')
        end

      end
    end
  end
end
