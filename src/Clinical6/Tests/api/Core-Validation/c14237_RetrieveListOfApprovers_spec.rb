require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "consent_approvers_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }

  it 'C14237 API Client should be able to retrieve the list of all the Approvers in the system', test_id: 'C14237' do
    test_rail_expected_steps(2)

    #Step1 Make a Get request on {{protocol}}{{url}}/v3/consent/approvers
    test_rail_expected_result(1, "It returns a 200 response and the list of existing approvers")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/approvers
    consent_approvers_index = V3::Consent::Approvers::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(1, "consent_approvers_index body header: #{consent_approvers_index.response.headers}")
    test_rail_result(1, "consent_approvers_index body: #{consent_approvers_index.response.body}")
    resp_code = consent_approvers_index.response.code
    resp_json = JSON.parse(consent_approvers_index.response.body)
    expect(resp_code).to eq 200
    test_rail_result(1, "consent_approvers_index response code: #{resp_code}", "pass")
    approver_id = resp_json['data'].all? { |id| id.dig('id') != nil}
    approver = resp_json['data'].all? { |type| type.dig('type') == "consent__approvers"}
    expect(approver_id).to be true
    expect(approver).to be true
    test_rail_result(1, "approver id(s) in response: #{approver_id}", "pass")
    test_rail_result(1, "approver list in response: #{approver}", "pass")

    #Step2 The unauthorized user makes a Get request on {{protocol}}{{url}}/v3/consent/approvers
    test_rail_expected_result(2, "It returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(2, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(2, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/approvers
    consent_approvers_index = V3::Consent::Approvers::Index.new(unauthorized_user_session.token, unauthorized_user_email, base_url)
    test_rail_result(2, "consent_approvers_index body header: #{consent_approvers_index.response.headers}")
    test_rail_result(2, "consent_approvers_index body: #{consent_approvers_index.response.body}")
    resp_code = consent_approvers_index.response.code
    expect(resp_code).to eq 403
    test_rail_result(2, "consent_approvers_index response code: #{resp_code}", "pass")
  end

end


