require_relative "../../base_api"

module V3
  module UserRoles
    class Create < BaseAPI

      attr_reader :email, :token, :environment, :name, :link

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "user_roles",
            "attributes": {
              "permanent_link": "#{link}",
              "name": "#{name}",
              "description": "This is a test user role"
            }
          }
        }
        JSON
      end

      private def post_create
        response = RestClient.post("https://#{@env}/v3/user_roles", payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response

      end

      def initialize(token, email, environment, name, link)
        @email = email
        @env = environment
        @token = token
        @name = name
        @link = link
      end

      def response
        @response ||= post_create
      end

      def user_role_id
        @user_role_id ||= JSON.parse(response.body).dig('data', 'id')
      end

    end
  end
end
