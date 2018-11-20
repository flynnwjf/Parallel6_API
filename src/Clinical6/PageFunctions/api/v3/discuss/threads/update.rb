require_relative "../../../base_api"

module V3
  module Discuss
    module Threads
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "attributes": {
                "status": "#{@status}"
              }
            }
          }
          JSON
        end

        private def update_session
          response = RestClient.patch("https://#{@env}/v3/discuss/threads/#{@id}",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :type, :id, :status

        def initialize(token, email, environment, id, status)
          @email = email
          @env = environment
          @token = token
          @id = id
          @status = status
        end

        def response
          @response ||= update_session
        end

      end
    end
  end
end
