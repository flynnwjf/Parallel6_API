require_relative "../../base_api"

module V3
  module StatusCheck
    class Create < BaseAPI

      def payload
        #type could be CrTrials::SiteMember
        @payload ||= JSON.parse(<<-JSON)
        {
          "data": {
            "type": "#{type}",
            "id": "1"
          }
        }
        JSON
      end

      private def post_create
        response = RestClient.post("https://#{@env}/v3/status_check", payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
        return response
      end

      attr_reader :email, :environment, :token, :type

      def initialize(token, email, environment, type)
        @email = email
        @env = environment
        @token = token
        @type = type
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
