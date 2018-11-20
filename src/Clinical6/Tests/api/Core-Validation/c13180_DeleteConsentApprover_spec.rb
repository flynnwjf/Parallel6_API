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
  let(:testname) { "consent_approvers_delete" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:type) { test_data["type"] }
  let(:approver_email) { test_data["email"] }


  it 'C13180 API Client should be able to delete a Consent::Approver', test_id: 'C13180' do
    test_rail_expected_steps(4)

    #Step1 The user makes a Delete request on {{protocol}}{{url}}/v3/consent/approvers/{{id}}
    test_rail_expected_result(1, "The result returns a 204 response. ")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    # Delete request on {{protocol}}{{url}}/v3/consent/approvers/{{id}}
    approver_id = V3::Consent::Approvers::Create.new(super_user_session.token, user_email, base_url, type, approver_email).id
    approver_destroy = V3::Consent::Approvers::Destroy.new(super_user_session.token, user_email, base_url, approver_id)
    resp_code = approver_destroy.response.code
    expect(resp_code).to eq 204
    test_rail_result(1, "approver_destroy header: #{approver_destroy.response.headers}")
    test_rail_result(1, "approver_destroy body: #{approver_destroy.response.body}")
    test_rail_result(1, "approver_destroy response code: #{resp_code}", "pass")

    #Step2 The user makes a Delete request on {{protocol}}{{url}}/v3/consent/approvers/{{id}} with invalid id
    test_rail_expected_result(2, "The result returns a 404 response with the error message detail Couldn't find Consent::Approver with 'id'={{id}}.")
    invalid_id = test_data["invalid_id"]
    approver_destroy = V3::Consent::Approvers::Destroy.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = approver_destroy.response.code
    expect(resp_code).to eq 404
    test_rail_result(2, "approver_destroy header: #{approver_destroy.response.headers}")
    test_rail_result(2, "approver_destroy body: #{approver_destroy.response.body}")
    test_rail_result(2, "approver_destroy response code: #{resp_code}", "pass")

    #Step3 The user makes a Get request on {{protocol}}{{url}}/v3/agreement/template_fields/:id with invalid id
    test_rail_expected_result(3, "The result returns a 200 response and returns the list of existing approvers.")
    approvers_index = V3::Consent::Approvers::Index.new(super_user_session.token, user_email, base_url)
    test_rail_result(3, "approvers_index header: #{approvers_index.response.headers}")
    test_rail_result(3, "approvers_index body: #{approvers_index.response.body}")
    resp_code = approvers_index.response.code
    resp_json = JSON.parse(approvers_index.response.body)
    expect(resp_code).to eq 200
    test_rail_result(3, "approvers_index response code: #{resp_code}", "pass")
    approver = resp_json['data'].any? { |email| email.dig('id') != approver_id}
    expect(approver).to be true
    test_rail_result(3, "approver id deleted and not in list: #{approver}", "pass")

    #Step4 The user makes a Delete request on {{protocol}}{{url}}/v3/consent/approvers/{{id}}
    test_rail_expected_result(4, "The result returns a 403 response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(4, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(4, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    approver_destroy = V3::Consent::Approvers::Destroy.new(unauthorized_user_session.token, unauthorized_user_email, base_url, 2)
    resp_code = approver_destroy.response.code
    expect(resp_code).to eq 403
    test_rail_result(4, "approver_destroy header: #{approver_destroy.response.headers}")
    test_rail_result(4, "approver_destroy body: #{approver_destroy.response.body}")
    test_rail_result(4, "approver_destroy response code: #{resp_code}", "pass")
  end

end