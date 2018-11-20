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
  let(:testname) { "consent_approvers_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:update_email) { test_data["email"] }
  let(:non_existing_approver) { test_data["invalid_id"] }
  let(:invalid_email) { test_data["invalid_email"] }
#Requests
  let(:user_role_id) { V3::UserRoles::Index.new(token, user_email, base_url).user_role_id}


  it 'C13234 SDK User should be able to update the information of an approver', test_id: 'C13234' do
    test_rail_expected_steps(6)

    #Step1 The user makes a Get request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    test_rail_expected_result(1, "User should see the approvers info in the response and should see a 200 OK status")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Get request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    list = V3::Consent::Approvers::Index.new(super_user_session.token, user_email, base_url)
    resp_code = list.response.code
    resp_json = JSON.parse(list.response.body)
    test_rail_result(1, "list approver header: #{list.response.headers}")
    test_rail_result(1, "list approver body: #{list.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "list of available approvers response code: #{resp_code}", "pass")
    id = resp_json['data'].all? { |approver| approver.dig('id') != nil }
    expect(id).to be true
    test_rail_result(1, "appriver id in response: #{id}", "pass")

    #Step2 The user makes a PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    test_rail_expected_result(2, "User should receive a response with those changes and should see a 200 OK status")
    #PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    id = resp_json.dig('data', 0, 'id')
    update = V3::Consent::Approvers::Update.new(super_user_session.token, user_email, base_url, id, update_email)
    resp_code = update.response.code
    resp_json = JSON.parse(update.response.body)
    test_rail_result(2, "update approver header: #{update.response.headers}")
    test_rail_result(2, "update approver body: #{update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(2, "updating approver response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'id')).to eq id
    expect(resp_json.dig("data", "attributes", "email")).to eq update_email
    test_rail_result(2, "updated email for appriver in response: #{update_email}", "pass")

    #Step3 The user makes a GET request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    test_rail_expected_result(3, "User should receive a response with those changes")
    #GET request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    show = V3::Consent::Approvers::Show.new(super_user_session.token, user_email, base_url, id)
    resp_code = show.response.code
    resp_json = JSON.parse(show.response.body)
    test_rail_result(3, "show approver header: #{show.response.headers}")
    test_rail_result(3, "show approver body: #{show.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "showing approver response code: #{resp_code}", "pass")
    expect(resp_json.dig('data', 'id')).to eq id
    expect(resp_json.dig("data", "attributes", "email")).to eq update_email
    test_rail_result(3, "updated email for appriver in response: #{update_email}", "pass")

    #Step4 The user makes a PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id} with non-existing approver
    test_rail_expected_result(4, "The user should receive a 404 Not Found status")
    #PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id} with non-existing approver
    update = V3::Consent::Approvers::Update.new(super_user_session.token, user_email, base_url, non_existing_approver, update_email)
    resp_code = update.response.code
    test_rail_result(4, "update approver header: #{update.response.headers}")
    test_rail_result(4, "update approver body: #{update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(4, "updating non-existing approver response code: #{resp_code}", "pass")

    #Step5 The user makes a PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id} with invalid parameter
    test_rail_expected_result(5, "User should receive a 422 Unprocessable Entity")
    #PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id} with invalid parameter
    update = V3::Consent::Approvers::Update.new(super_user_session.token, user_email, base_url, id, invalid_email)
    resp_code = update.response.code
    test_rail_result(5, "update approver header: #{update.response.headers}")
    test_rail_result(5, "update approver body: #{update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(5, "updating approver with invalid parameter response code: #{resp_code}", "pass")

    #Step6 The unauthorized user makes a PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    test_rail_expected_result(6, "User should receive a 403 Forbidden")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(6, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(6, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #PATCH request on {{protocol}}{{url}}/v3/consent/approvers/{id}
    update = V3::Consent::Approvers::Update.new(unauthorized_user_session.token, unauthorized_user_email, base_url, id, update_email)
    resp_code = update.response.code
    test_rail_result(6, "update approver header: #{update.response.headers}")
    test_rail_result(6, "update approver body: #{update.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(6, "updating approver response code: #{resp_code}", "pass")
  end

end

