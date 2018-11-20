require_relative "../../../base_api"

module V3
  module Agreement
    module TemplateFields
      class Destroy < BaseAPI

        private def destroy_session
          response = RestClient.delete("https://#{@env}/v3/agreement/template_fields/#{@template_field_id}",
                                       { content_type: :json,
                                         'X-User-Token' => @token,
                                         'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
          return response
        end

        attr_reader :email, :password, :environment

        def initialize(token, email, environment, template_field_id)
          @email = email
          @env = environment
          @token = token
          @template_field_id = template_field_id
        end

        def response
          @response ||= destroy_session
        end

      end
    end
  end
end
