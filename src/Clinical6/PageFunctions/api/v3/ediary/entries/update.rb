require_relative "../../../base_api"

module V3
  module Ediary
    module Entries
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "ediary_entries",
              "attributes": {
                "date": "#{date}"
              },
              "relationships": {
                "owner": {
                  "data": {
                    "type": "mobile_users",
                    "id": #{mobile_id}
                  }
                }
              }
            }
          }
          JSON
        end

        private def update
          response = RestClient.patch("https://#{@env}/v3/ediary/entries/#{id}", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :mobile_id, :id, :date

        def initialize(token, email, environment, id, mobile_id, date)
          @email = email
          @env = environment
          @token = token
          @id = id
          @mobile_id = mobile_id
          @date = date
        end

        def response
          @response ||= update
        end

      end
    end
  end
end
