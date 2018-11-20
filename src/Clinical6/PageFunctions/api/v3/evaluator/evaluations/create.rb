require_relative "../../../base_api"

module V3
  module Evaluator
    module Evaluations
      class Create < BaseAPI

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "evaluator_evaluations",
              "attributes": {
                "permanent_link": "#{link}",
                "name": "#{name}"
              }
            }
          }
          JSON
        end

        private def post_create
          response = RestClient.post("https://#{@env}/v3/evaluator/evaluations", payload.to_json,
                                     { content_type: :json,
                                       'X-User-Token' => @token,
                                       'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end

        attr_reader :email, :environment, :name, :link

        def initialize(token, email, environment, name, link)
          @email = email
          @env = environment
          @token = token
          @name = name
          @link = link
        end

        def response
          @response ||= post_create
        end

        def id
          @id ||= JSON.parse(response).dig('data', 'id')
        end

      end
    end
  end
end
