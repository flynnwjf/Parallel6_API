require_relative "../../base_api"
require "base64"

module V3
  module FileUploads
    class Post < BaseAPI
        private def post_upload
          payload = { :id => @id, :type => @type, :file => @file, :attribute => @attribute }

          response = RestClient.post("https://#{@environment}/v3/file_uploads",
                                     payload,
                                     { 'X-User-Token' => @token, 'X-User-Username' => @email }
          ) { |response, request, result| response }
          BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s, payload.to_s)

          return response
        end

        attr_reader :token, :email, :environment, :id, :type, :file, :attribute

        def initialize(token, email, environment, id, type,
                       file = File.new(File.dirname(__FILE__) + '/AgreementTemplate.pdf'),
                       attribute = 'document')
          @token = token
          @email = email
          @environment = environment
          @id = id
          @type = type
          @file = file
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
