require_relative "../../../base_api"

module V3
  module MobileUser
    module Profile
      class Update < BaseAPI

      attr_reader :token, :environment, :id, :first_name, :last_name, :timezone, :terms_of_use_accepted_at, :privacy_policy_accepted_at

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "profiles",
            "attributes": {
              "first_name": "#{first_name}",
              "last_name": "#{last_name}",
              "timezone": "#{timezone}",
              "terms_of_use_accepted_at" : "#{terms_of_use_accepted_at}",
              "privacy_policy_accepted_at": "#{privacy_policy_accepted_at}"
            }
          }
        }
        JSON
      end

      private def update
        response = RestClient.patch("https://#{@env}/v3/mobile_users/#{@id}/profile", payload.to_json,
                                    { content_type: :json, Accept: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email

                                    }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      def initialize(id, token, auth_user_email, environment, first_name, last_name, timezone = 'America/Tijuana', privacy_policy_accepted_at = Date.today,terms_of_use_accepted_at = Date.today )
        @token = token
        @env = environment
        @id = id
        @first_name = first_name
        @last_name = last_name
        @email = auth_user_email
        @timezone = timezone
        @terms_of_use_accepted_at = terms_of_use_accepted_at
        @privacy_policy_accepted_at = privacy_policy_accepted_at

      end

      def response
        @response ||= update
      end

      end
    end
  end
end
