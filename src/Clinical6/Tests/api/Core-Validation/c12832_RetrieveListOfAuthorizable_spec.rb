require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
#Test Info
  let(:testname) { "authorizables_list" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C12832 Admin User should be able to retrieve the list of authorizable resources that can be used to create a Permission' , test_id: 'C12832' do
    test_rail_expected_steps(1)

    #Step1 Make a Get request on v3/authorizables
    test_rail_expected_result(1, "User can get 200 response that includes all authorized resources for a permission with each resource's ID and Type")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    authorizable = V3::Authorizables::List.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "authorizable header: #{authorizable.response.headers}")
    test_rail_result(1, "authorizable body: #{authorizable.response.body}")
    resp_json = JSON.parse(authorizable.response.body)
    expect(authorizable.response.code).to eq 200
    test_rail_result(1, "authorizable entities response code: #{authorizable.response.code}")
    id = resp_json['data'].all? { |entities| entities.dig('id') != nil }
    type = resp_json['data'].all? { |entities| entities.dig('type') != nil }
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "id(s) contained in response: #{id}")
    test_rail_result(1, "type(s) contained in response: #{type}", "pass")
  end

end


