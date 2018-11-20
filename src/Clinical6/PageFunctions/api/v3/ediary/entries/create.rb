require_relative "../../../base_api"

module V3
  module Ediary
    module Entries
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "ediary_entries",
              "attributes": {
                "date": "2018-06-11"
              },
              "relationships": {
                "template": {
                  "data": {
                    "type": "ediary__entry_templates",
                    "id": 1
                  }
                },
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

        private def post_create
          response = RestClient.post("https://#{@env}/v3/ediary/entries/", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :mobile_id

        def initialize(token, email, environment, mobile_id)
          @email = email
          @env = environment
          @token = token
          @mobile_id = mobile_id
        end

        def response
          @response ||= post_create
        end

        def id
          @id ||= JSON.parse(response).dig('data', 'id')
        end

        def group_id
          @group_id ||= JSON.parse(response).dig('data', 'relationships', 'entry_group', 'data', 'id')
        end

      end
    end
  end
end
