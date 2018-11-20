require_relative "../../../base_api"

module V3
  module MobileUser
    module Badges
      class Create < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {},
                    "relationships": {
                        "mobile_users": {
                           "data": {
                               "type": "mobile_users",
                                "id": "#{@mobile_user_id}"
                            }
                         },
                        "rewards": {
                           "data": {
                                "type": "rewards",
                                 "id": "#{@badge_id}"
                            }
                        }
                     }                     
                }   
           }
        JSON
      end

      private def create_session
        response = RestClient.post("https://#{@env}/v3/mobile_users/#{@mobile_user_id}/badges",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }

        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)

        return response
      end

      attr_reader :email, :env, :token, :type, :mobile_user_id, :badge_id

      def initialize(token, email, environment, type, mobile_user_id, badge_id)
        @email = email
        @env = environment
        @token = token
        @type = type
        @mobile_user_id = mobile_user_id
        @badge_id = badge_id
      end

      def response
        @response ||= create_session
      end

      def id
        @id ||= JSON.parse(response).dig('data', 'id')
      end

      end
    end
  end
end
