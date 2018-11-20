require_relative "../../base_api"

module V3
  module Locations
    class Update < BaseAPI

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "locations",
            "attributes": {
              "title": "#{title}",
              "street": "Main",
              "city": "Orange City",
              "state": "CA",
              "country": "USA"
            }
          }
        }
        JSON
      end

      private def patch_update
        response = RestClient.patch("https://#{@env}/v3/locations/#{id}", payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :title, :id

      def initialize(token, email, environment, id, title)
        @email = email
        @env = environment
        @token = token
        @id = id
        @title = title
      end

      def response
        @response ||= patch_update
      end

    end
  end
end
