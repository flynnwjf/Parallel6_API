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
  let(:testname) { "consent_approvers_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:approver_email) { test_data["email"] }


  it 'C13188 Developer should be able to add new Approvers to the Document', test_id: 'C13188' do
    test_rail_expected_steps(3)

    #Step1 The user makes a POST request on {{protocol}}{{url}}/v3/consent/approvers
    test_rail_expected_result(1, "An approver should get added to the consent document and should receive a 201 Created")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/consent/approvers
    approver = V3::Consent::Approvers::Create.new(super_user_session.token, user_email, base_url, type, approver_email)
    resp_code = approver.response.code
    resp_json = JSON.parse(approver.response.body)
    test_rail_result(1, "approver header: #{approver.response.headers}")
    test_rail_result(1, "approver body: #{approver.response.body}")
    expect(resp_code).to eq 201
    test_rail_result(1, "creating new approver response code: #{resp_code}", "pass")
    approver_id = resp_json.dig('data', 'id')
    expect(approver_id).not_to eq nil
    test_rail_result(1, "created approver id in response: #{approver_id}", "pass")

    #Step2 The user makes a GET request on /v3/consent/approvers to check
    test_rail_expected_result(2, "The user receives a 200OK and is able to view the created approver")
    #GET request on /v3/consent/approvers
    show_approver = V3::Consent::Approvers::Show.new(super_user_session.token, user_email, base_url, approver_id)
    resp_code = show_approver.response.code
    test_rail_result(2, "show_approver header: #{show_approver.response.headers}")
    test_rail_result(2, "show_approver body: #{show_approver.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "showing created approver response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a POST request on {{protocol}}{{url}}/v3/consent/approvers
    test_rail_expected_result(3, "The user gets 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #POST request on {{protocol}}{{url}}/v3/consent/approvers
    approver = V3::Consent::Approvers::Create.new(unauthorized_user_session.token, unauthorized_user_email, base_url, type, approver_email)
    resp_code = approver.response.code
    test_rail_result(3, "approver header: #{approver.response.headers}")
    test_rail_result(3, "approver body: #{approver.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "creating new approver response code: #{resp_code}", "pass")
  end

end

