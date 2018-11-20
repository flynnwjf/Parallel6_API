require_relative "../../../base_api"

module V3
  module Trials
    module SiteContacts
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
                       "first_name": "#{@first_name}",
                       "last_name": "#{@last_name}",
                       "email": "#{@contact_email}"
                    },
                    "relationships": {
                         "site": {
                             "data": {
                                 "id": "#{@site_id}",
                                 "type": "trials__site"
                             }
                         }
                     }
                   
                }   
           }
          JSON
        end

        private def create_session
          response = RestClient.post("https://#{@env}/v3/trials/site_contacts",
                                     payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }


          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :token, :type, :first_name, :last_name, :contact_email, :site_id

        def initialize(token, email, environment, type, first_name, last_name, contact_email, site_id)
          @email = email
          @env = environment
          @token = token
          @type = type
          @first_name = first_name
          @last_name = last_name
          @contact_email = contact_email
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
