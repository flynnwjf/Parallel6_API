require_relative "../../../base_api"

module V3
  module Trials
    module SiteMember
     class Create < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
                       "member_type": "patient"
                    },
                    "relationships": {
                         "mobile_user": {
                             "data": {
                                 "id": "#{@mobile_user_id}",
                                 "type": "mobile_users"
                             }
                         },
                         "site": {
                              "data": {
                                   "type": "trials__sites",
                                   "id": 1
                               }
                         }
                     }
                }   
           }
        JSON
      end

      private def create_session
        response = RestClient.post("https://#{@env}/v3/trials/site_members",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }


        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :type, :mobile_user_id

      def initialize(token, email, environment, type, mobile_user_id)
        @email = email
        @env = environment
        @token = token
        @type = type
        @mobile_user_id = mobile_user_id

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
