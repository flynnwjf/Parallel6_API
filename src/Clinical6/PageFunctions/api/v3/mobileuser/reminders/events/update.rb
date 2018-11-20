require_relative "../../../../base_api"

module V3
  module MobileUser
    module Reminders
      module Events
        class Update < BaseAPI

          attr_reader :email, :token, :env, :id, :title, :mobile_id, :rule_id

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "reminder__events",
              "attributes": {
                "extras": {
                  "title": "#{title}",
                  "site": "test-site"
                }
              },
              "relationships": {
                "mobile_users": {
                  "data": {
                    "type": "mobile_users",
                    "id": #{mobile_id}
                  }
                },
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

        private def update
          response = RestClient.patch("https://#{@env}/v3/mobile_users/#{mobile_id}/reminder_events/#{id}", payload.to_json,
                                    { content_type: :json, Accept: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        def initialize(token, email, environment, id, title, mobile_id, rule_id)
          @email = email
          @env = environment
          @token = token
          @id = id
          @title = title
          @mobile_id = mobile_id
          @rule_id = rule_id
        end

        def response
          @response ||= update
        end

        end
      end
    end
  end
end
