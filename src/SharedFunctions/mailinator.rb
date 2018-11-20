require 'json'
require 'rest-client'

class Mailinator

  @@mailinator_token = '20cf21802f1a4fe18eebcb2e8efdc901'

  def self.get_first_email_id (email_address)
    url = "https://api.mailinator.com/api/inbox?to=#{email_address}@parallel6&token=#{@@mailinator_token}&private_domain=true"

    response = RestClient.get(url)
    #puts response

    parsed_json = JSON.parse(response)
    if parsed_json['messages'].any?
      first_email_id = parsed_json['messages'][0]['id']
    else
      return 0
    end


  end


  def self.get_last_email_body (email_address, email_body_start = '', email_body_end = '')

    first_email_id = get_first_email_id(email_address)
    if first_email_id != 0
      
      url = "https://api.mailinator.com/api/email?id=#{first_email_id}&token=#{@@mailinator_token}&private_domain=true"
      response = RestClient.get(url)

      from_field = JSON.parse(response)['data']['from']
      subject = JSON.parse(response)['data']['subject']
      email_body = JSON.parse(response)['data']['parts'][0]['body']

      return email_body[/#{email_body_start}(.*?)#{email_body_end}/m, 1]
    else
      return "No emails found"
    end
    # puts 'full inv. url: ' + full_invitation_url
    # puts 'from: ' + from_field
    # puts 'subject: ' + subject
    # puts 'invitation_token: ' + invitation_token
    # #puts email_body

  end
end