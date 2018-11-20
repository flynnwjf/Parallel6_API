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


  it 'C14271 The System should allow users to view a virtually signed/fully executed patient ICF within the patient profile', test_id: 'C14271' do
    test_rail_expected_steps(1)

    #Step1 The user makes a GET Request on /admin/agreement_signatures?mobile_user_id={{mobile_user_id}}
    test_rail_expected_result(1, "The user receives a 200 OK response and is able to view the URL of the signed document Document URL")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Mobile User Session
    mobile_user_session = V3::MobileUser::Session::Create.new(mobile_email, mobile_password, base_url, device_id)
    test_rail_result(1, "Mobile User session body header: #{mobile_user_session.response.headers}")
    test_rail_result(1, "Mobile User session body: #{mobile_user_session.response.body}")
    mobile_user_id = mobile_user_session.mobile_user_id
    #GET Request on /admin/agreement_signatures?mobile_user_id={{mobile_user_id}}
    agreement_signatures = V2::Agreements::Show.new(super_user_session.token, user_email, base_url, mobile_user_id)
    resp_code = agreement_signatures.response.code
    resp_json = JSON.parse(agreement_signatures.response.body)
    test_rail_result(1, "agreement_signatures header: #{agreement_signatures.response.headers}")
    test_rail_result(1, "agreement_signatures body: #{agreement_signatures.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting agreement signatures response code: #{resp_code}", "pass")
    if(resp_json.size > 10)
      expect(resp_json.dig('data','attributes','document_url')).not_to eq nil
    end
  end

end

