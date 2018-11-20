require_relative "../../../base_api"

module V3
  module DataCollection
    module CapturedValueGroups
      class Update < BaseAPI

      attr_reader :email, :token, :environment, :id, :enabled

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "id": #{id},
            "type": "data_collection__captured_value_groups",
            "attributes": {
              "final_submission": #{enabled}
            }
          }
        }
        JSON
      end

      private def update
        response = RestClient.patch("https://#{@env}/v3/data_collection/captured_value_groups/#{@id}", payload.to_json,
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
        @response ||= update
      end

      end
    end
  end
end
