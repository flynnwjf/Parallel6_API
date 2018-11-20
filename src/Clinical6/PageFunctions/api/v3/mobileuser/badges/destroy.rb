require_relative "../../../base_api"

module V3
  module MobileUser
    module Badges
     class Destroy < BaseAPI

      private def destroy_session
        response = RestClient.delete("https://#{@env}/v3/mobile_users/#{@mobile_user_id}/badges/#{@id}",
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
        return response
      end

      attr_reader :email, :token, :env, :id, :mobile_user_id

      def initialize(token, email, environment, mobile_user_id, id)
        @email = email
        @env = environment
        @token = token
        @mobile_user_id = mobile_user_id
        @id = id
      end

      def response
        @response ||= destroy_session
      end

     end
    end
  end
end
