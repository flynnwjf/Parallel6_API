require_relative "../../../../base_api"

module V3
  module MobileUser
    module Scheduler
      module PersonalizedRuleSchedules
        class Create < BaseAPI

          attr_reader :email, :token, :env, :mobile_id, :rule_id

          def payload
            @payload ||= JSON.parse(<<-JSON)
            {
              "data": {
                "type": "personalized_rule_schedules",
                "attributes": {
                  "start_date": "2017-06-04",
                  "enabled": true
                },
                "relationships": {
                  "scheduleable": {
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

          private def create
            response = RestClient.post("https://#{@env}/v3/mobile_users/#{mobile_id}/scheduler/personalized_rule_schedules", payload.to_json,
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          def initialize(token, email, environment, mobile_id, rule_id)
            @email = email
            @env = environment
            @token = token
            @mobile_id = mobile_id
            @rule_id = rule_id
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
end
