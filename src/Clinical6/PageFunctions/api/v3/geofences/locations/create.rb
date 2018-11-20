require_relative "../../../base_api"

module V3
  module Geofences
    module Locations
     class Create < BaseAPI

      # memoize  @payload = @payload || something
      def payload
        @payload ||= JSON.parse(<<-JSON)
          {    
	             "data": {
	                 	"type": "#{@type}",
		                "attributes": {
                       "title": "#{@title}",
                       "latitude":"#{@latitude}",
                       "longitude":"#{@longitude}"
                    }
                }   
           }
        JSON
      end

      private def create_session
        response = RestClient.post("https://#{@env}/v3/geofences/#{@geofence_id}/locations",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }

        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)

        return response
      end

      attr_reader :email, :env, :token, :geofence_id, :type, :title, :latitude, :longitude

      def initialize(token, email, environment, geofence_id, type, title, latitude, longitude)
        @email = email
        @env = environment
        @token = token
        @geofence_id = geofence_id
        @type = type
        @title = title
        @latitude = latitude
        @longitude = longitude
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
