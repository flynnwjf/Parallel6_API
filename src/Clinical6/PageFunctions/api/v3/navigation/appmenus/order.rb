require_relative "../../../base_api"

module V3
  module Navigation
    module AppMenus
      class Order < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "navigation__app_menus",
              "attributes": {
                "#{id}": {
                  "position": #{id}
                }
              }
            }
          }
          JSON
        end

        private def post_order
          response = RestClient.post("https://#{@env}/v3/navigation/app_menus/order", payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id

        def initialize(token, email, environment, id)
          @email = email
          @env = environment
          @token = token
          @id = id
        end

        def response
          @response ||= post_order
        end

      end
    end
  end
end
