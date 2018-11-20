require_relative "../../../base_api"

module V3
  module DataCollection
    module CapturedValueGroups
      class Show < BaseAPI

        private def get_show
          response = RestClient.get("https://#{@env}/v3/mobile_users/#{mobile_user_id}/data_collection/captured_value_groups/#{group_id}",
                                       { content_type: :json,
                                         'X-User-Token' => @token,
                                         'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :token, :env, :group_id, :mobile_user_id

        def initialize(token, email, environment, mobile_user_id, group_id)
          @email = email
          @env = environment
          @token = token
          @mobile_user_id = mobile_user_id
          @group_id = group_id
        end

        def response
          @response ||= get_show
        end

      end
    end
  end
end
