require_relative "../../../base_api"

module V3
  module Discuss
    module Threads
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "threads",
              "attributes": {
                "status": "open"
              },
              "relationships": {
                "commentable" : {
                  "data": {
                    "type": "data_collection__flow_processes",
                    "id": #{flow_process_id}
                  }
                }
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/discuss/threads",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :flow_process_id

        def initialize(token, email, environment, flow_process_id)
          @email = email
          @env = environment
          @token = token
          @flow_process_id = flow_process_id
        end

        def response
          @response ||= post_create
        end

        def id
          @id ||= JSON.parse(response.body).dig('data', 'id')
        end

      end
    end
  end
end
