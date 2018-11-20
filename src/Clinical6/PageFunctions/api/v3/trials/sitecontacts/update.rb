require_relative "../../../base_api"

module V3
  module Trials
    module SiteContacts
      class Update < BaseAPI

        attr_reader :email, :token, :environment, :id, :firstname, :lastname

        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
            "data": {
              "type": "trials__site_contacts",
              "attributes": {
                "first_name": "#{@firstname}",
                "last_name": "#{@lastname}",
                "email": "jonathan.kerluke@bashirianbartoletti.io"
              }
            }
          }
          JSON
        end

        private def update
          response = RestClient.patch("https://#{@env}/v3/trials/site_contacts/#{@id}", payload.to_json,
                                      { content_type: :json,
                                        'X-User-Token' => @token,
                                        'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end


        def initialize(token, email, environment, id, firstname, lastname)
          @email = email
          @env = environment
          @token = token
          @id = id
          @firstname = firstname
          @lastname = lastname
        end

        def response
          @response ||= update
        end

        def firstname
          @firstname ||= JSON.parse(response).dig('data', 'attributes', 'first_name')
        end

        def lastname
          @lastname ||= JSON.parse(response).dig('data', 'attributes', 'last_name')
        end

      end
    end
  end
end
