require_relative "../../../../base_api"

module V3
  module MobileUser
    module Scheduler
      module PersonalizedRuleSchedules
        class Show < BaseAPI

          attr_reader :email, :token, :env, :mobile_id

          private def show
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{mobile_id}/scheduler/personalized_rule_schedules",
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          def initialize(token, email, environment, mobile_id)
            @email = email
            @env = environment
            @token = token
            @mobile_id = mobile_id
          end

          def response
            @response ||= show
          end

        end
      end
    end
  end
end
