require_relative "../../base_api"

module V3
  module TemporaryIdentifier
    class Create < BaseAPI

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "temporary_identifiers",
            "relationships": {
              "user": {
                "data": {
                  "id": "#{id}",
                  "type": "mobile_users"
                }
              }
            }
          }
        }
        JSON
      end

      private def post_create
        response = RestClient.post("https://#{@env}/v3/temporary_identifiers",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :id

      def initialize(token, email, environment, id)
        @email = email
        @env = environment
        @token = token
        @id = id
      end

      def response
        @response ||= post_create
      end

      def identifier
        @identifier ||= JSON.parse(response).dig('data', 'attributes', 'token')
      end

    end
  end
end
