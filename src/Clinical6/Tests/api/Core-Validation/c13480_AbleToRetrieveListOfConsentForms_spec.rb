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
  let(:testname) { "consent_forms_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests

  it 'C13480 API Client should be able to retrieve the list of Consent::Form', test_id: 'C13480' do
    test_rail_expected_steps(2)

    #Step1 In GET tool V3 go to Consent > Forms > Retrieve list of Consent Forms.
    test_rail_expected_result(1, "200 response and returns the list of existing consent forms.")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "User session body: #{super_user_session.response.body}")

    consent_forms_index = V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "consent_forms header: #{consent_forms_index.response.headers}")
    test_rail_result(1, "consent_forms body: #{consent_forms_index.response.body}")
    expect(consent_forms_index.response.code).to eq 200

    expect(JSON.parse(consent_forms_index.response.body).dig("data", 0, "id")).not_to eq nil
    expect(JSON.parse(consent_forms_index.response.body).dig("data", 0, "type")).to eq "consent__forms"
    test_rail_result(1, "consent_forms body was not empty: true")
    test_rail_result(1, "consent_forms body contained 'consent__forms': true")
    test_rail_result(1, "consent_forms response code: #{consent_forms_index.response.code}", "pass")

    #Step2 An unauthorized user (not an admin or superuser) send the GET request
    env_user = DataHandler.get_env_user(env_info, :unauthorized_user)
    user_email = env_user["email"]
    user_password = env_user["password"]
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(2, "User session body header: #{super_user_session.response.headers}")
    test_rail_result(2, "User session body: #{super_user_session.response.body}")

    consent_forms_index = V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(2, "consent_forms header: #{consent_forms_index.response.headers}")
    test_rail_result(2, "consent_forms body: #{consent_forms_index.response.body}")
    expect(consent_forms_index.response.code).to eq 403
    test_rail_result(2, "consent_forms response code: #{consent_forms_index.response.code}", "pass")
  end


end

