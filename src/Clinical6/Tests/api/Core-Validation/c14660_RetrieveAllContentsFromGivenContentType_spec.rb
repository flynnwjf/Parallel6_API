require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:mobile_user) { DataHandler.get_env_user(env_info, :mobile_user) }
  let(:mobile_email) { mobile_user["email"] }
  let(:mobile_password) { mobile_user["password"] }
  let(:device_id) { mobile_user["device_id"] }
  let(:super_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { super_user["email"] }
  let(:user_password) { super_user["password"] }
#Test Info
  let(:testname) { "dynamiccontent_contents_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }


  it 'C14660 The System Administrator should to be able to retrieve all the contents from a given content type that are associated with a mobile user', test_id: 'C14660' do
    test_rail_expected_steps(5)

    #Step1 Make a POST request on {{protocol}}{{url}}/v3/mobile_users/sessions
    test_rail_expected_result(1, "The mobile user session is created and response includes the mobile user id")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    resp_code = mobile_user_session.response.code
    expect(resp_code).to eq 200
    test_rail_result(1, "creating mobile user session response code: #{resp_code}", "pass")

    #Step2 Make a GET request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/dynamic_content/contents
    test_rail_expected_result(2, "The user receives 200 with no content in data attribute.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "Super User session body: #{super_user_session.response.body}")
    #GET request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/dynamic_content/contents
    mobileuser_dynamiccontent_contents = V3::MobileUser::DynamicContent::Contents::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_dynamiccontent_contents.response.code
    test_rail_result(2, "mobileuser_dynamiccontent_contents header: #{mobileuser_dynamiccontent_contents.response.headers}")
    test_rail_result(2, "mobileuser_dynamiccontent_contents body: #{mobileuser_dynamiccontent_contents.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "listing mobile user dynamic contents response code: #{resp_code}", "pass")

    #Step3 Make a GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types
    test_rail_expected_result(3, "Returns 200 with the user content types and its attributes, including content_type_id")
    #GET request on {{protocol}}{{url}}/v3/dynamic_content/content_types
    content_types_index = V3::DynamicContent::ContentTypes::Index.new(super_user_session.token, user_email, base_url)
    resp_code = content_types_index.response.code
    type_id = content_types_index.id
    test_rail_result(3, "content_types_index header: #{content_types_index.response.headers}")
    test_rail_result(3, "content_types_index body: #{content_types_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "listing content types response code: #{resp_code}", "pass")

    #Step4 Make a POST request on {{protocol}}{{url}}/v3/dynamic_content/contents
    test_rail_expected_result(4, "The user received 201 created")
    #POST request on {{protocol}}{{url}}/v3/dynamic_content/contents
    contents_create = V3::DynamicContent::Contents::Create.new(super_user_session.token, user_email, base_url, type, type_id, mobile_user_id)
    resp_code = contents_create.response.code
    content_id = contents_create.id
    test_rail_result(4, "contents_create header: #{contents_create.response.headers}")
    test_rail_result(4, "contents_create body: #{contents_create.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(4, "creating content response code: #{resp_code}", "pass")

    #Step5 Make a GET request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/dynamic_content/contents
    test_rail_expected_result(5, "The user receives 200 with the user associated content types")
    #GET request on {{protocol}}{{url}}/v3/mobile_users/{{mobile_user_id}}/dynamic_content/contents
    mobileuser_dynamiccontent_contents = V3::MobileUser::DynamicContent::Contents::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = mobileuser_dynamiccontent_contents.response.code
    test_rail_result(5, "mobileuser_dynamiccontent_contents header: #{mobileuser_dynamiccontent_contents.response.headers}")
    test_rail_result(5, "mobileuser_dynamiccontent_contents body: #{mobileuser_dynamiccontent_contents.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(5, "listing mobile user dynamic contents response code: #{resp_code}", "pass")
    id = JSON.parse(mobileuser_dynamiccontent_contents.response.body)['data'].any? { |data| data.dig('id') == "#{content_id}"}
    expect(id).to be true
    test_rail_result(5, "created dynamic content is associated with mobile user in response: #{id}", "pass")
  end

end


