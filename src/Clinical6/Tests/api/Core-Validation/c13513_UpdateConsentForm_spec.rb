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
  let(:testname) { "consent_forms_update" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "UpdateForm-" + Time.new.strftime("%Y%m%d%H%M%S") }


  it 'C13513 API Client should be able to update a Consent Form', test_id: 'C13513' do
    test_rail_expected_steps(6)

    #Step1 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/forms
    test_rail_expected_result(1, "It returns a 200 response and the details of the updated consent form")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #Patch request on {{protocol}}{{url}}/v3/consent/forms
    #The last form in form list
    form_id = V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url).id
    form_update = V3::Consent::Forms::Update.new(super_user_session.token, user_email, base_url, form_id, name)
    resp_code = form_update.response.code
    resp_json = JSON.parse(form_update.response.body)
    test_rail_result(1, "form_update header: #{form_update.response.headers}")
    test_rail_result(1, "form_update body: #{form_update.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "updating consent form response code: #{resp_code}", "pass")
    expect(resp_json.dig("data", "attributes", "name")).to eq name
    test_rail_result(1, "updating consent form name in response: #{name}", "pass")

    #Step2 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/forms with invalid id
    test_rail_expected_result(2, "REST Tool returns a 404 response with the error message detail Couldn't find Consent::Form with 'id'={{id}}.")
    #Patch request on {{protocol}}{{url}}/v3/consent/forms
    invalid_id = test_data["invalid_id"]
    form_update = V3::Consent::Forms::Update.new(super_user_session.token, user_email, base_url, invalid_id, name)
    resp_code = form_update.response.code
    test_rail_result(2, "form_update header: #{form_update.response.headers}")
    test_rail_result(2, "form_update body: #{form_update.response.body}")
    expect(resp_code).to eq 404
    test_rail_result(2, "updating consent form response code: #{resp_code}", "pass")

    #Step3 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/forms with long name
    test_rail_expected_result(3, "REST Tool returns a 500 error.")
    #Patch request on {{protocol}}{{url}}/v3/consent/forms
    long_name = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
    form_update = V3::Consent::Forms::Update.new(super_user_session.token, user_email, base_url, form_id, long_name)
    resp_code = form_update.response.code
    test_rail_result(3, "form_update header: #{form_update.response.headers}")
    test_rail_result(3, "form_update body: #{form_update.response.body}")
    expect(resp_code).to eq 500
    test_rail_result(3, "updating consent form response code: #{resp_code}", "pass")

    #Step4 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/forms with same name
    test_rail_expected_result(4, "REST Tool returns a 422 response with the error message detail has already been taken.")
    #Patch request on {{protocol}}{{url}}/v3/consent/forms
    #The name of first form in form list
    existing_name = JSON.parse(V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url).response.body).dig("data", 0, "attributes", "name")
    test_rail_result(4, "existing name is: #{existing_name}")
    form_update = V3::Consent::Forms::Update.new(super_user_session.token, user_email, base_url, form_id, existing_name)
    resp_code = form_update.response.code
    test_rail_result(4, "form_update header: #{form_update.response.headers}")
    test_rail_result(4, "form_update body: #{form_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(4, "updating consent form response code: #{resp_code}", "pass")

    #Step5 The user makes a Patch request on {{protocol}}{{url}}/v3/consent/forms with invalid name
    test_rail_expected_result(5, "REST Tool returns a 422 response with the error message detail can't be blank.")
    #Patch request on {{protocol}}{{url}}/v3/consent/forms
    invalid_name = ""
    form_update = V3::Consent::Forms::Update.new(super_user_session.token, user_email, base_url, form_id, invalid_name)
    resp_code = form_update.response.code
    test_rail_result(5, "form_update header: #{form_update.response.headers}")
    test_rail_result(5, "form_update body: #{form_update.response.body}")
    expect(resp_code).to eq 422
    test_rail_result(5, "updating consent form response code: #{resp_code}", "pass")

    #Step6 The user makes a Get request on {{protocol}}{{url}}/v3/consent/forms
    test_rail_expected_result(6, "REST Tool returns a 200 response and lists the existing consent forms.")
    #Get request on {{protocol}}{{url}}/v3/consent/forms
    form_index = V3::Consent::Forms::Index.new(super_user_session.token, user_email, base_url)
    resp_code = form_index.response.code
    resp_json = JSON.parse(form_index.response.body)
    test_rail_result(6, "form_index header: #{form_index.response.headers}")
    test_rail_result(6, "form_index body: #{form_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(6, "getting consent form response code: #{resp_code}", "pass")
    update_name = resp_json['data'].any? { |n| n.dig('attributes', 'name') == name}
    expect(update_name).to be true
    test_rail_result(6, "getting updated consent form name in response: #{update_name}", "pass")
  end

end

