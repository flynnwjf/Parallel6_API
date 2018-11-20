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
  let(:testname) { "datacollection_flowprocesses_create" }
  let(:test_data) { DataHandler.get_test_data(testname) }
  let(:name) { "TestFlow" + Time.new.strftime("%Y%m%d%H%M%S") }
  let(:link) { "test_flow_" + Time.new.strftime("%Y-%m-%d-%H-%M-%S") }


  it 'C13806 Allows user to save the CRF', test_id: 'C13806' do
    test_rail_expected_steps(3)

    #Step1 The user makes a GET {{protocol}}{{url}}/v3/data_collection/flow_processes
    test_rail_expected_result(1, "user receives a 200, All flow processes already created are displayed")
    #Super User Session
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET {{protocol}}{{url}}/v3/data_collection/flow_processes
    datacollection_flowprocesses_index = V3::DataCollection::FlowProcesses::Index.new(super_user_session.token, user_email, base_url)
    resp_code = datacollection_flowprocesses_index.response.code
    test_rail_result(1, "datacollection_flowprocesses_index header: #{datacollection_flowprocesses_index.response.headers}")
    test_rail_result(1, "datacollection_flowprocesses_index body: #{datacollection_flowprocesses_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting data collection flow processes response code: #{resp_code}", "pass")

    #Step2 The user makes a POST {{protocol}}{{url}}/v3/data_collection/flow_processes
    test_rail_expected_result(2, "the user receives a 200, The data is submitted and captured")
    #POST {{protocol}}{{url}}/v3/data_collection/flow_processes
    datacollection_flowprocesses_create = V3::DataCollection::FlowProcesses::Create.new(super_user_session.token, user_email, base_url, name, link)
    resp_code = datacollection_flowprocesses_create.response.code
    resp_json = JSON.parse(datacollection_flowprocesses_create.response.body)
    test_rail_result(2, "datacollection_flowprocesses_create header: #{datacollection_flowprocesses_create.response.headers}")
    test_rail_result(2, "datacollection_flowprocesses_create body: #{datacollection_flowprocesses_create.response.body}")
    expect(resp_code).to eq 201
    id = resp_json.dig('data', 'id')
    expect(id).not_to eq ""
    test_rail_result(2, "created data collection flow process id in response: #{id}", "pass")

    #Step3 The user makes a GET {{protocol}}{{url}}/v3/data_collection/flow_processes
    test_rail_expected_result(3, "user receives a 200, The new added flow process should be displayed in the list now")
    #GET {{protocol}}{{url}}/v3/data_collection/flow_processes
    datacollection_flowprocesses_index = V3::DataCollection::FlowProcesses::Index.new(super_user_session.token, user_email, base_url)
    resp_code = datacollection_flowprocesses_index.response.code
    resp_json = JSON.parse(datacollection_flowprocesses_index.response.body)
    test_rail_result(3, "datacollection_flowprocesses_index header: #{datacollection_flowprocesses_index.response.headers}")
    test_rail_result(3, "datacollection_flowprocesses_index body: #{datacollection_flowprocesses_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(3, "getting data collection flow processes response code: #{resp_code}", "pass")
    created_id = resp_json['data'].any? { |data| data.dig('id') == "#{id}"}
    expect(created_id).to be true
    test_rail_result(3, "created data collection flow process id in response: #{created_id}", "pass")
  end

end

