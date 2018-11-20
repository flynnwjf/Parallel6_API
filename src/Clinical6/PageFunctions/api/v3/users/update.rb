require_relative "../../base_api"

module V3
  module Users
    class Update < BaseAPI

      attr_reader :email, :token, :environment, :id, :enabled

      def payload
        @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
                "attributes": {
                      "enabled": #{@enabled}
                }
            }
          }
        JSON
      end

      private def update_user_attr
        response = RestClient.patch("https://#{@env}/v3/users/#{@id}", payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response

      end

      def initialize(token, email, environment, id, enabled)
        @email = email
        @env = environment
        @token = token
        @id = id
        @enabled = enabled
      end


      def response
        @response ||= update_user_attr
      end

      def disabled_date
        @disabled_date ||= JSON.parse(response.body).dig('data', 'attributes', 'disabled_at')
      end

    end
  end
end
