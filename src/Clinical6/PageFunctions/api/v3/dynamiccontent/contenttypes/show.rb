require_relative "../../../base_api"

module V3
  module DynamicContent
    module ContentTypes
      class Show < BaseAPI

        private def show_session
          response = RestClient.get("https://#{@env}/v3/dynamic_content/content_types/#{@id}",
                                    { content_type: :json,
                                      'X-User-Token' => @token,
                                      'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :token, :env, :id

        def initialize(token, email, environment, id)
          @email = email
          @env = environment
          @token = token
          @id = id
        end

        def response
          @response ||= show_session
        end

      end
    end
  end
end
