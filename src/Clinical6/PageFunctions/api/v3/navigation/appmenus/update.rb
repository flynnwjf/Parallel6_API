require_relative "../../../base_api"

module V3
  module Navigation
    module AppMenus
      class Update < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "nativation__app_menus",
              "attributes": {
                "title": "#{title}",
                "enabled": "#{enabled}"
              }
            }
          }
          JSON
        end

        private def patch_update
          response = RestClient.patch("https://#{@env}/v3/navigation/app_menus/#{id}", payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id, :title, :enabled

        def initialize(token, email, environment, id, title, enabled=false)
          @email = email
          @env = environment
          @token = token
          @id = id
          @title = title
          @enabled = enabled
        end

        def response
          @response ||= patch_update
        end

      end
    end
  end
end
