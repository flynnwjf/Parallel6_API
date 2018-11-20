require_relative "../../../PageFunctions/api/base_api"

module MAILINATOR
  class GetInbox < BaseAPI

    private def get_inbox

      response = RestClient.get("https://api.mailinator.com/api/inbox?to=#{email}@parallel6&token=20cf21802f1a4fe18eebcb2e8efdc901&private_domain=true",
                                { content_type: :json }) { |response, request, result| response }
      BaseAPI.print_request_response(response.headers.to_s, response.body.to_s, response.request.inspect + response.request.headers.to_s)
      return response
    end

    attr_reader :email

    def initialize(email)
      @email = email
    end

    def response
       @response ||= get_inbox
    end

    def first_email_id
      @first_email_id ||= JSON.parse(response).dig('messages', 0, 'id')
    end

  end
end

