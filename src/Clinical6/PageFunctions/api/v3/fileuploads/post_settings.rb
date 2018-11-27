require_relative "../../base_api"

module V3
  module FileUploads
      class PostSettings < BaseAPI

        private def post_upload
          payload = { :id => @id, :type => 'settings',:file => @file , :attribute => @attribute,:multipart => true}

          response = RestClient.post("https://#{@env}/v3/file_uploads",
                                     payload,
                                    {'X-User-Token' => @token, 'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload)
          return response
        end

        attr_reader :email, :password, :environment, :id, :file

        def initialize(token, email, environment, id, file, attribute)
          @email = email
          @env = environment
          @token = token
          @id = id
          @file = file
          if (@file == 'new')
            @file = File.new(File.dirname(__FILE__) + '/logo-nav.PNG')
          elsif (@file == 'large')
            @file = File.new(File.dirname(__FILE__) + '/20MSample.jpg')
          end
          @attribute = attribute
        end

        def response
          @response ||= post_upload
        end

        def url
          @url ||= JSON.parse(response.body).dig("file_url")
        end

      end
  end
end
