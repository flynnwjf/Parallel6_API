require_relative "../../base_api"
module V2
  module Agreements
    class RequestSign < BaseAPI

      def payload
        @payload ||= JSON.parse(<<-JSON)
        {
          "agreement_template_id":"#{@templ_id}",
          "recipients":[{"email":"#{@rec_email}","role":"SIGNER","signing_order":1,"signing_password":"1212"}],
          "options": {"flow_process_id":8}
        }

        JSON
      end


      private def request_sign

        response = RestClient.post("https://#{@env}/api/v2/agreements/request_sign",
                                   payload.to_json,
                                   { content_type: :json,
                                     'X-User-Token' => @token,
                                     'X-User-Username' => @email }
        ) { |response, request, result| response }
        BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect, payload.to_s)
        return response

      end

      attr_reader :email, :password, :environment

      def initialize(token, email, environment, recepient_email, template_id)
        @token = token
        @env = environment
        @rec_email = recepient_email
        @templ_id = template_id
        @email = email

      end

      def response
        @response ||= request_sign
      end

      def sign_url
        @token ||= JSON.parse(response).dig('signatures', 0, 'sign_url')
      end
    end
  end
end

