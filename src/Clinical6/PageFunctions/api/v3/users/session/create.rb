require_relative "../../../base_api"

module V3
  module Users
    module Session
      class Create < BaseAPI

        # memoize  @payload = @payload || something
        def payload
          @payload ||= JSON.parse(<<-JSON)
          {
              "data":{
                  "type":"sessions",
                  "attributes":{
                      "email":"#{email}",
                      "password":"#{password}"
                  }
              }
          }
          JSON
        end

        # V3_users_session.new(email, password).create_session
        private def create_session

          response = RestClient.post("https://#{@env}/v3/users/session",
                                     payload.to_json,
                                     { content_type: :json }) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s,response.request.inspect + response.request.headers.to_s, payload.to_s)
          return response
        end


        # attr_reader is shortcut for creates a function
        # def email
        #   @email
        # end
        attr_reader :email, :password, :environment

        def initialize(email, password, environment)
          @email = email
          @password = password
          @env = environment
        end

        def response
          # memoize  @response = @response || create_session
          # a += 2
          # a = a + 2
          # ruby or returns the first items that is not nil or false  2 || 5 || 3
          # ruby and returns the first nil or false, or the last value  8 && nil && false && 7
          @response ||= create_session
        end

        # V3_users_session.new(email, password).token
        def token
          @token ||= JSON.parse(response).dig('data', 'attributes', 'authentication_token')
        end

        def user_id
          @user_id ||= JSON.parse(response).dig('data', 'id')
        end

        def email
          @email ||= JSON.parse(response).dig('data', 'attributes', 'email')
        end

        def user_type
          @user_type ||= JSON.parse(response).dig('included', 1, 'attributes', 'permanent_link')
        end

      end
    end
  end
end
