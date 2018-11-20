require_relative "../../../base_api"

module V3
  module MobileUser
    module Profile
      class UpdateLanguage < BaseAPI

      attr_reader :token, :environment, :id, :language_id

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "profiles",
            "attributes": {},
            "relationships": {
              "language": {
                "data": {
                  "type": "languages",
                  "id": "#{language_id}"
                }
              }
            }
          }
        }
        JSON
      end

      private def update_langauge
        response = RestClient.patch("https://#{@env}/v3/mobile_users/#{@id}/profile", payload.to_json,
                                    { content_type: :json, Accept: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      def initialize(id, token,auth_user_email, environment, language_id)
        @token = token
        @env = environment
        @id = id
        @email = auth_user_email
        @language_id = language_id
      end


      def response
        @response ||= update_langauge
      end

      end
    end
  end
end
