require_relative "../../../base_api"

module V3
  module Navigation
    module AppMenus
      class Delete < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "options": {
              "cascade": "#{cascade}"
            }
          }
          JSON
        end

        private def delete
          response = RestClient::Request.execute(method: :delete, url: "https://#{@env}/v3/navigation/app_menus/#{id}",
                                      payload: payload, headers: { content_type: :json,
                                                                   'X-User-Token' => @token,
                                                                   'X-User-Username' => @email }

          # response = RestClient.delete("https://#{@env}/v3/navigation/app_menus/#{id}",
          #                           { content_type: :json,
          #                             'X-User-Token' => @token,
          #                             'X-User-Username' => @email }

          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :id, :cascade

        def initialize(token, email, environment, id, cascade = "false")
          @email = email
          @env = environment
          @token = token
          @id = id
          @cascade = cascade
        end

        def response
          @response ||= delete
        end

      end
    end
  end
end
