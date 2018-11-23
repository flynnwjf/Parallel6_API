require_relative '../../../../../src/spec_helper'

context 'Core Test', test_rail: true do

#Environment Info
  let(:env_info) { DataHandler.get_env(TestEnv) }
  let(:base_url) { env_info["base_url"] }
#Main User(s)
  let(:env_user) { DataHandler.get_env_user(env_info, :super_user) }
  let(:user_email) { env_user["email"] }
  let(:user_password) { env_user["password"] }

  it 'C12760 SDK User should be able to retrieve all the "Dynamic Attributes" associated with a content type', test_id: 'C12760' do
    test_rail_expected_steps(1)

    #Step1 Make a GET request on /v3/data_collection/flow_processes
    test_rail_expected_result(1, "User can get 200 response and get a list of all flow processes with limited attributes of name, permanent_link, description and published_at")
    super_user_session = V3::Users::Session::Create.new(user_email, user_password, base_url)
    test_rail_result(1, "Super User session body header: #{super_user_session.response.headers}")
    test_rail_result(1, "Super User session body: #{super_user_session.response.body}")
    #GET request on /v3/data_collection/flow_processes
    datacollection_flowprocesses_index = V3::DataCollection::FlowProcesses::Index.new(super_user_session.token, user_email, base_url)
    resp_code = datacollection_flowprocesses_index.response.code
    resp_json = JSON.parse(datacollection_flowprocesses_index.response.body)
    test_rail_result(1, "datacollection_flowprocesses_index header: #{datacollection_flowprocesses_index.response.headers}")
    test_rail_result(1, "datacollection_flowprocesses_index body: #{datacollection_flowprocesses_index.response.body}")
    expect(resp_code).to eq 200
    test_rail_result(1, "getting data collection flow processes response code: #{resp_code}", "pass")
    id = resp_json['data'].all?{|data|data.dig('id') != nil}
    type = resp_json['data'].all?{|data|data.dig('type') == "data_collection__flow_processes"}
    expect(id).to be true
    expect(type).to be true
    test_rail_result(1, "ids are in response: #{id}", "pass")
    test_rail_result(1, "types are in response: #{type}", "pass")
  end

end


