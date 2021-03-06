require_relative "../../../base_api"

module V3
  module Geofences
    module Locations
      class Destroy < BaseAPI

       private def destroy_session
         response = RestClient.delete("https://#{@env}/v3/geofences/#{@geofence_id}/locations/#{@id}",
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
         ) { |response, request, result| response }
         BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
         return response
       end

      attr_reader :email, :token, :env, :geofence_id, :id

      def initialize(token, email, environment, geofence_id, id)
        @email = email
        @env = environment
        @token = token
        @geofence_id = geofence_id
        @id = id
      end

      def response
        @response ||= destroy_session
      end

      end
    end
  end
end
