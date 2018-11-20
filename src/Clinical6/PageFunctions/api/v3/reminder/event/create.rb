require_relative "../../../base_api"

module V3
  module Reminder
    module Event
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "reminder__events",
              "attributes": {
                "extras": {
                  "some": "extra_parameters"
                },
                "date": "2016-06-06T00:00:00Z",
                "source_type": "manual"
              },
              "relationships": {
                "reminder__rules": {
                  "data": {
                    "type": "reminder__rules",
                    "id": #{rule_id}
                  }
                },
                "mobile_users": {
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

        private def post_create
          response = RestClient.post("https://#{@env}/v3/reminder/events", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :token, :rule_id, :mobile_id

        def initialize(token, email, environment, rule_id, mobile_id)
          @email = email
          @env = environment
          @token = token
          @rule_id = rule_id
          @mobile_id = mobile_id
        end

        def response
          @response ||= post_create
        end

        def id
          @id ||= JSON.parse(response).dig('data', 'id')
        end

      end
    end
  end
end
