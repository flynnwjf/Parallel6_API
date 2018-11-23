require_relative "../../../../base_api"

module V3
  module MobileUser
    module Notifications
      module Deliveries
        class Show < BaseAPI

          private def get_show
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{mobile_id}/notifications/deliveries/#{id}",
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          attr_reader :email, :token, :env, :id, :mobile_id

          def initialize(token, email, environment, id, mobile_id)
            @email = email
            @env = environment
            @token = token
            @id = id
            @mobile_id = mobile_id
          end

          def response
            @response ||= get_show
          end

        end
      end
    end
  end
end
