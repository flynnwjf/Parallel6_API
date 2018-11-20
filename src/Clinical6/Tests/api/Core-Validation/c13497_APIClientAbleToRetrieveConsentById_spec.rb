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

#Preconditions
  let(:pre_testname) { "consent_approvers_create" }
  let(:pre_test_data) { DataHandler.get_test_data(pre_testname) }
  let(:type) { pre_test_data["type"] }
  let(:approver_email) { pre_test_data["email"] }
#Test Info
  let(:testname) { "consent_approvers_show" }
  let(:test_data) { DataHandler.get_test_data(testname) }
#Requests


  it 'C13497 API Client should be able to retrieve a Consent::Approver by ID', test_id: 'C13497' do
    test_rail_expected_steps(3)


    #Step1 The user makes a Post request on {{protocol}}{{url}}/v3/mobile_users
    test_rail_expected_result(1, "200 response, and only the details of the specified approver ID are returned.")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")

    consent_approvers_create = V3::Consent::Approvers::Create.new(super_user_session.token, user_email, base_url, type, approver_email)
    expect(consent_approvers_create.response.code).to eq 201
    id = consent_approvers_create.id
    test_rail_result(1, "id under under test: #{id}", "pass")

    consent_approvers_show = V3::Consent::Approvers::Show.new(super_user_session.token, user_email, base_url, id)
    test_rail_result(1, "consent_approvers_show header: #{consent_approvers_show.response.headers}")
    test_rail_result(1, "consent_approvers_show body: #{consent_approvers_show.response.body}")
    expect(consent_approvers_show.response.code).to eq 200
    expect(JSON.parse(consent_approvers_show.response).dig('data', 'id')).to eq id
    test_rail_result(1, "consent_approvers_show response code: #{consent_approvers_show.response.code}", "pass")

    #Step2 Replace {{id}} with an invalid ID and click Send.
    test_rail_expected_result(2, " 404 response ")
    consent_approvers_show = V3::Consent::Approvers::Show.new(super_user_session.token, user_email, base_url, "111111111")
    test_rail_result(2, "consent_approvers_show header: #{consent_approvers_show.response.headers}")
    test_rail_result(2, "consent_approvers_show body: #{consent_approvers_show.response.body}")
    expect(consent_approvers_show.response.code).to eq 404
    test_rail_result(2, "consent_approvers_show response code: #{consent_approvers_show.response.code}", "pass")

    #Step3 Using an unauthorized user Make a request using REST Tool to: GET request "{{protocol}}{{url}}/v3/consent/approvers/{{id}}
    test_rail_expected_result(3, " 401 response ")
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    consent_approvers_show = V3::Consent::Approvers::Show.new(unauthorized_user_session, unauthorized_user_email, base_url, id)
    test_rail_result(3, "consent_approvers_show header: #{consent_approvers_show.response.headers}")
    test_rail_result(3, "consent_approvers_show body: #{consent_approvers_show.response.body}")
    expect(consent_approvers_show.response.code).to eq 401
    #cleanup
    expect(V3::Consent::Approvers::Destroy.new(super_user_session.token, user_email, base_url, id).response.code).to eq 204
    test_rail_result(3, "consent_approvers_show response code: #{consent_approvers_show.response.code}", "pass")
  end
end



