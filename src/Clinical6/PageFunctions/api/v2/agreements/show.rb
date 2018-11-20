require_relative "../../base_api"

module V2
  module Agreements
      class Show < BaseAPI

        private def show
          response = RestClient.get("https://#{@env}/admin/agreement_signatures?mobile_user_id=#{mobile_user_id}",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :mobile_user_id

        def initialize(token, email, environment, mobile_user_id)
          @email = email
          @env = environment
          @token = token
          @mobile_user_id = mobile_user_id
        end

        def response
          @response ||= show
        end

      end
   end
end
