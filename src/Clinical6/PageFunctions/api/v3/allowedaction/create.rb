require_relative "../../base_api"

module V3
  module AllowedAction
    class Create < BaseAPI

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "allowed_actions",
            "attributes": {
              "name": "#{name}"
            },
            "relationships": {
              "permission": {
                "data": {
                  "id": 1,
                  "type": "permissions"
                }
              }
            }
          }
        }
        JSON
      end

      private def post_create
        response = RestClient.post("https://#{@env}/v3/allowed_actions",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :name, :id

      def initialize(token, email, environment, name)
        @email = email
        @env = environment
        @token = token
        @name = name
      end

      def response
        @response ||= post_create
      end

      def id
        @id ||= JSON.parse(response).dig('data', 'id')
      end

    end
  end
end
