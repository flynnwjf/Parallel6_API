require_relative "../../../../base_api"

module V3
  module Consent
    module Forms
      module FormVesions
        class List < BaseAPI

          private def list_session
            response = RestClient.get("https://#{@env}/v3/consent/forms/#{@form_version_id}/consent/form_versions",
                                      { content_type: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
            ) { |response, request, result| response }
            BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
            return response
          end

          attr_reader :email, :token, :env, :form_version_id

          def initialize(token, email, environment,form_version_id)
            @email = email
            @env = environment
            @token = token
            @form_version_id = form_version_id
          end

          def response
            @response ||= list_session
          end
        end
      end
    end
  end
end
