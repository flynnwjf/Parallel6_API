require_relative "../../base_api"

module V3
  module Menus
    class Update < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "title": "#{title}",
			                  "enabled": true
                    },
                   "relationships": {
			                  "authorizable": {
				                 "data":null
			                   }	
	                	}	
                }
           }
        JSON
      end
      private def update_session
        response = RestClient.patch("https://#{@env}/v3/menus/#{@id}",
                                    payload.to_json,
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :token, :environment, :type, :title

      def initialize(token, email, environment, id, type, title)
        @email = email
        @env = environment
        @token = token
        @id = id
        @type = type
        @title = title
      end

      def response
        @response ||= update_session
      end

    end
  end
end
