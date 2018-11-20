require_relative "../../../base_api"

module V3
  module Evaluator
    module Evaluations
      class Index < BaseAPI

        private def get_index
          response = RestClient.get("https://#{@env}/v3/evaluator/evaluations",
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :environment

        def initialize(token, email, environment)
          @email = email
          @env = environment
          @token = token
        end

        def response
          @response ||= get_index
        end

        def count
          @id ||= JSON.parse(response)["data"].size
        end

        def id
          @id ||= JSON.parse(response).dig('data', count-1, 'id')
        end

      end
    end
  end
end
