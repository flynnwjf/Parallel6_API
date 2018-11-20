require_relative "../../base_api"

module V3
  module Badges
    class Create < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
			                  "title": "#{title}",
			                  "description": "#{@description}"
                    }
                }
           }
        JSON
      end

      private def create_session
        response = RestClient.post("https://#{@env}/v3/badges",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }

        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :type, :title, :description

      def initialize(token, email, environment, type, title, description)
        @email = email
        @env = environment
        @token = token
        @type = type
        @title = title
        @description = description
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
