require_relative "../../../base_api"

module V3
  module MobileUser
    module Invitations
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "invitations",
		                "attributes": {
			                  "email": "#{@invitation_email}",
			                  "member_type": "#{@member_type}",
                        "first_name": "#{first_name}",
                        "last_name": "#{last_name}"
                    },
                    "relationships": {
                         "user_role": {
                             "data": {
                                   "id": #{user_role_id},
                                   "type": "user_roles"
                              }
                         },
                        "site": {
                          "data": {
                            "id": #{site_id},
                            "type": "trials__sites"
                          }
                        }
                    }
                }
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/mobile_users/invitation",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :token, :invitation_email, :member_type, :first_name, :last_name, :user_role_id, :site_id

        def initialize(token, email, environment, invitation_email, member_type, first_name, last_name, user_role_id, site_id)
          @email = email
          @env = environment
          @token = token
          @invitation_email = invitation_email
          @member_type = member_type
          @first_name = first_name
          @last_name = last_name
          @user_role_id = user_role_id
          @site_id = site_id
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
