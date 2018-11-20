require 'testrail_client'
require 'json'

def test_rails_client(username, password)
  client = TestRail::APIClient.new('https://parallel6.testrail.com/')
  client.user = username
  client.password = password
  return client
end

def get_id_for_project(test_rail_client, project_name = "P6 - mClinical")
#Get all projects
  project = test_rail_client.send_get('get_projects')
  specific_project = JSON.parse(project.to_json).find do |project|
    project.dig('name') == project_name
  end
  return specific_project.dig('id')
end

def get_run_id(test_rail_client, specific_test_run_name, project_id)
#get specific run
  runs = test_rail_client.send_get("get_runs/#{project_id}")
  specific_run = JSON.parse(runs.to_json).find do |runs|
    runs.dig('name') == specific_test_run_name
  end
  return specific_run.dig('id')
end

def get_test_tid(test_rail_client, test_cid, test_run_id)
  tests_in_run = test_rail_client.send_get("get_tests/#{test_run_id}")
  t_id = tests_in_run.find do |test|
    test.dig('case_id') == test_cid.to_i
  end
  # puts "t_id - #{t_id}"
  return t_id.dig('id')
end

#1 = passed
#5 = failed
def test_result_json
  @test_result_json = JSON.parse(<<-JSON)
          { 
            "status_id": "1",
            "comment" : "This test worked fine!",
            "custom_step_results": [
              {
                "content": "Step 1",
                "actual": "Actual Result Test Pavel failed",
                "status_id": 1
              },
              { "content": "Step 2",
                "actual": "TActual Result Test Pavel failed",
                "status_id": 1
              }

              ]
          }
  JSON
end

#
#puts "payload: #{payload}"

def update_test_results(test_rail_client, test_tid, test_result_json)
#update results
#
  begin
    r = test_rail_client.send_post("add_result/#{test_tid}", test_result_json)
  rescue StandardError => e
    puts e.message
    #puts e.backtrace.inspect
  end
end

client = test_rails_client('shainskypavel@parallel6.com', 'Charm009!!')
run_id = get_run_id(client, "Ignore this one - API", get_id_for_project(client))
test_tid =  get_test_tid(client,"12841", run_id)
update_test_results(client, test_tid, test_result_json)
#98388

=begin

puts r
# results_for_test_id = client.send_get("get_results/#{test_id}")
# puts "results_for_test_id: #{results_for_test_id.to_json}"
# puts results_for_test_id.dig("status_id")

#results_for_run = client.send_get("get_results_for_case/629/12551")
#puts results_for_run.to_json
#puts clinical6_projectid
=begin
# #get plans
plans = client.send_get("get_plans/#{clinical6_projectid}")
puts "plans: #{plans}"

#get suites
suites = client.send_get("get_suites/#{clinical6_projectid}")
puts "suites: #{suites}"


#results_for_test_id = client.send_get("get_results/#{test_id}")
#puts "results_for_test_id: #{results_for_test_id}"
#puts results_for_test_id.dig("status_id")
#get results for run
#get_results_for_run = client.send_get("get_results_for_run/#{specific_api_run_id}")
#puts "get_results_for_run: #{get_results_for_run.to_json}"
#puts get_results_for_run.dig('test_id')

#46251
#results_for_run = client.send_get("get_results/98388")
#puts results_for_run.to_json
#12841

=end


