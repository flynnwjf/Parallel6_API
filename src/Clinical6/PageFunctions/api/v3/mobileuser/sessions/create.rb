require_relative "../../../base_api"

module V3
  module MobileUser
    module Session
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "sessions",
              "attributes": {
                "email": "#{email}",
                "password": "#{password}"
              },
              "relationships": {
                "devices": {
                  "data": {
                    "type": "devices",
                    "id": "#{id}"
                  }
                }
              }
            }
          }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/mobile_users/sessions",
                                     payload.to_json,
                                     { content_type: :json }) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id

        def initialize(email, password, environment, id)
          @email = email
          @password = password
          @env = environment
          @id = id
        end

        def response
          @response ||= create_session
        end

        def token
          @token ||= JSON.parse(response).dig('included', 0 ,'attributes', 'access_token')
        end

        def mobile_user_id
          @mobile_user_id ||= JSON.parse(response).dig('data', 'id')
        end

        def email
          @email ||= JSON.parse(response).dig('data', 'attributes', 'email')
        end

      end
    end
  end
end
