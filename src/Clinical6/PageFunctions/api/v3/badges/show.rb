require_relative "../../base_api"

module V3
  module Badges
      class Show < BaseAPI

        private def show_session
          response = RestClient.get("https://#{@env}/v3/badges/#{@user_id}",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment, :user_id

        def initialize(token, email, environment, user_id)
          @email = email
          @env = environment
          @token = token
          @user_id = user_id
        end

        def response
          @response ||= show_session
        end

      end
  end
end
