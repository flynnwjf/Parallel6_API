require_relative "../../../../base_api"

module V3
  module MobileUser
    module DataCollection
      module CapturedValueGroups
        class Index < BaseAPI

          private def get_index
            response = RestClient.get("https://#{@env}/v3/mobile_users/#{mobile_user_id}/data_collection/captured_value_groups",
                                      { content_type: :json, Accept: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          attr_reader :email, :token, :env, :mobile_user_id

          def initialize(token, email, environment, mobile_user_id)
            @email = email
            @env = environment
            @token = token
            @mobile_user_id = mobile_user_id
          end

          def response
            @response ||= get_index
          end

          def id
            @id ||= JSON.parse(response).dig('data', 0, 'id')
          end

        end
      end
    end
  end
end
