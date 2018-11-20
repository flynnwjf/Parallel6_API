require_relative "../../base_api"

module V3
  module MobileUser
    class Update < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
                       "email": "#{@mobile_user_email}"
                    },
                    "relationships": {
                         "user_role": {
                             "data": {
                                 "id": "2",
                                 "type": "user_role"
                             }
                         }
                     }
                }   
           }
        JSON
      end

      private def update_session
        response = RestClient.patch("https://#{@env}/v3/mobile_users/#{@id}",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }

        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :type, :mobile_user_email, :id

      def initialize(token, email, environment, type, mobile_user_email, id)
        @email = email
        @env = environment
        @token = token
        @type = type
        @mobile_user_email = mobile_user_email
        @id = id
      end

      def response
        @response ||= update_session
      end

    end
  end
end
