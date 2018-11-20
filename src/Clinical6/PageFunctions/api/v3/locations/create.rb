require_relative "../../base_api"

module V3
  module Locations
    class Create < BaseAPI

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "locations",
            "attributes": {
              "title": "#{title}",
              "street": "Main",
              "city": "San Diego",
              "state": "CA",
              "country": "USA"
            }
          }
        }
        JSON
      end

      private def post_create
        response = RestClient.post("https://#{@env}/v3/locations", payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :title

      def initialize(token, email, environment, title)
        @email = email
        @env = environment
        @token = token
        @title = title
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
