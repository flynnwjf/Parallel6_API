require_relative "../../../base_api"

module V3
  module Reminder
    module Event
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "reminder__events",
              "attributes": {
                "extras": {
                  "some": "#{para}"
                }
              },
              "relationships": {
                "reminder__rules": {
                  "data": {
                    "type": "reminder__rules",
                    "id": #{rule_id}
                  }
                }
              }
            }
          }
          JSON
        end

        private def patch_update
          response = RestClient.patch("https://#{@env}/v3/reminder/events/#{id}", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :token, :rule_id, :id, :para

        def initialize(token, email, environment, id, rule_id, para)
          @email = email
          @env = environment
          @token = token
          @id = id
          @rule_id = rule_id
          @para = para
        end

        def response
          @response ||= patch_update
        end

      end
    end
  end
end
