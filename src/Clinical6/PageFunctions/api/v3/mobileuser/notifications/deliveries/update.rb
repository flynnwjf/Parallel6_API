require_relative "../../../../base_api"

module V3
  module MobileUser
    module Notifications
      module Deliveries
        class Update < BaseAPI

          attr_reader :email, :token, :env, :id, :mobile_id, :status

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "notification_deliveries",
              "attributes": {
                "status": "#{status}"
              }
            }
          }
          JSON
        end

        private def update
          response = RestClient.patch("https://#{@env}/v3/mobile_users/#{mobile_id}/notifications/deliveries/#{id}", payload.to_json,
                                    { content_type: :json, Accept: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        def initialize(token, email, environment, id, mobile_id, status)
          @email = email
          @env = environment
          @token = token
          @id = id
          @mobile_id = mobile_id
          @status = status
        end

        def response
          @response ||= update
        end

        end
      end
    end
  end
end
