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
  let(:unauthorized_user) { DataHandler.get_env_user(env_info, :unauthorized_user) }
  let(:unauthorized_user_email) { unauthorized_user["email"] }
  let(:unauthorized_user_password) { unauthorized_user["password"] }
#Test Info
  let(:testname) { "mobileuser_agreement_index" }
  let(:test_data) { DataHandler.get_test_data(testname) }


  it 'C13323 API Client should be able to retrieve all the agreements that are associated with a mobile user', test_id: 'C13323' do
    test_rail_expected_steps(3)

    #Step1 Make a Get request on /v3/mobile_users/:id/agreement/agreements
    test_rail_expected_result(1, "User can get 200 response")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #Get request on /v3/mobile_users/:id/agreement/agreements
    agreements = V3::MobileUser::Agreement::Index.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = agreements.response.code
    test_rail_result(1, "agreements header: #{agreements.response.headers}")
    test_rail_result(1, "agreements body: #{agreements.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "listing all the agreements associated with a mobile user response code: #{resp_code}", "pass")

    #Step2 Make a Get request on /v3/mobile_users/:id/agreement/agreements with invalid parameter
    test_rail_expected_result(2, "User can get Not Found 404 response")
    #Get request on /v3/mobile_users/:id/agreement/agreements
    invalid_id = test_data["invalid_id"]
    agreements = V3::MobileUser::Agreement::Index.new(super_user_session.token, user_email, base_url, invalid_id)
    resp_code = agreements.response.code
    test_rail_result(2, "agreements header: #{agreements.response.headers}")
    test_rail_result(2, "agreements body: #{agreements.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "listing all the agreements associated with a mobile user response code: #{resp_code}", "pass")

    #Step3 The unauthorized user makes a Get request on /v3/mobile_users/:id/agreement/agreements
    test_rail_expected_result(3, "User can get Forbidden response")
    #Unauthorized User Session
    unauthorized_user_session = V3::Users::Session::Create.new(unauthorized_user_email, unauthorized_user_password, base_url)
    test_rail_result(3, "Unauthorized User session body header: #{unauthorized_user_session.response.headers}")
    test_rail_result(3, "Unauthorized User session body: #{unauthorized_user_session.response.body}")
    #Get request on /v3/mobile_users/:id/agreement/agreements
    agreements = V3::MobileUser::Agreement::Index.new(unauthorized_user_session.token, unauthorized_user_email, base_url, mobile_user_id)
    resp_code = agreements.response.code
    test_rail_result(3, "agreements header: #{agreements.response.headers}")
    test_rail_result(3, "agreements body: #{agreements.response.body}")
    expect(resp_code).to eq 403
    test_rail_result(3, "listing all the agreements associated with a mobile user response code: #{resp_code}", "pass")
  end

end


