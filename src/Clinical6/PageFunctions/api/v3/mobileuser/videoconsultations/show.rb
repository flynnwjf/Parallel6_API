require_relative "../../../base_api"

module V3
  module MobileUser
    module VideoConsultations
      class Show < BaseAPI

      attr_reader :token, :email, :environment, :id

      private def get_show
        response = RestClient.get("https://#{@env}/v3/mobile_users/#{id}/video_consultations",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
        return response
      end

      def initialize(token, email, environment, id)
        @token = token
        @email = email
        @env = environment
        @id = id
      end

      def response
        @response ||= get_show
      end

      end
    end
  end
end
