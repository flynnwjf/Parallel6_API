require_relative "../../base_api"

module V3
  module UserRoles
    class Index < BaseAPI

      private def get_index
        response = RestClient.get("https://#{@env}/v3/user_roles",
                                  { content_type: :json,
                                    'X-User-Token' => @token,
                                    'X-User-Username' => @email }
        ) { |response, _request, _result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
        response
      end

      attr_reader :email, :password, :environment

      def initialize(token, email, environment)
        @email = email
        @env = environment
        @token = token
      end

      def response
        @response ||= get_index
      end

      def user_role_id
        @user_role_id ||= response_as_json.dig("data", 0, "id")
      end

      def super_user_id
        @super_user_id ||= super_user_hash.dig('id')
      end

      def guest_user_id
        @guest_user_id ||= guest_user_hash.dig('id')
      end

      private

      def response_as_json
        @response_as_json ||= JSON.parse(response.body)
      end

      def super_user_hash
        response_as_json['data'].find do |user_role|
          user_role.dig('attributes', 'is_super')
          #user_role.dig('attributes', 'permanent_link') == 'superuser'
        end
      end
      def guest_user_hash
        response_as_json['data'].find do |user_role|
          #user_role.dig('attributes', 'is_super')
          user_role.dig('attributes', 'permanent_link') == 'guest'
        end
      end
    end
  end
end
