require 'testrail_client'
require 'json'
require 'socket'

require_relative './test_rails_slack_notification'

module TestRailLibrary

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
    #http://docs.gurock.com/testrail-api2/reference-results#add_results_for_cases
    # @test_result_json = JSON.parse(<<-JSON)
    #       {
    #         "status_id": "1",
    #         "comment" : "This test worked fine!",
    #         "custom_step_results": [
    #           {
    #             "content": "Step 1",
    #             "actual": "Actual Result Test Pavel failed",
    #             "status_id": 1
    #           },
    #           { "content": "Step 2",
    #             "actual": "Actual Result Test Pavel failed",
    #             "status_id": 1
    #           }
    #
    #           ]
    #       }
    # JSON
  end

#
#puts "payload: #{payload}"

  def update_test_results(test_rail_client, test_tid, test_result_json)
    begin
      r = test_rail_client.send_post("add_result/#{test_tid}", test_result_json)
    rescue StandardError => e
      puts e.message
      #puts e.backtrace.inspect
    end
  end

  def test_rail_before
    @result = { status_id: nil, comment: nil, elapsed: nil, custom_step_results: [] }
  end

  def test_rail_update_test_result(test_id, test_rail_credentials, test_rail_run_name, execution_time)

    # puts test_id
    # puts test_rail_credentials[:username]
    # puts test_rail_run_name
    expect_steps = @result.delete(:expected_steps)
    raise StandardError.new('Must define expected steps at the beginning of the test') if expect_steps.nil?


    #if number of steps did not match expected number of steps
    if expect_steps == @result[:custom_step_results].count { :content }
      @result[:status_id] = 1
    else
      @result[:status_id] = 5
      @result[:comment] = "Number of expected steps #{expect_steps} was not equal to number of recorded steps #{@result[:custom_step_results].count { :content }} \n"
    end

    #if any of the steps had a failed result
    any_failed_steps = @result[:custom_step_results].find do |step_name|
      step_name[:status_id] != 1
    end
    if any_failed_steps
      @result[:status_id] = 5
      @result[:comment] = @result[:comment].to_s + " One or more of test steps failed \n"
    end


    @result[:comment] = @result[:comment].to_s + " Executed on #{Socket.gethostname} Execution Time: #{execution_time}s"
    @result[:elapsed] = "#{execution_time}s"

    tr_client = test_rails_client(test_rail_credentials[:username], test_rail_credentials[:password])
    test_run_id = get_run_id(tr_client, test_rail_run_name, get_id_for_project(tr_client))
    test_tid = get_test_tid(tr_client, test_id, test_run_id)
    puts "result: #{@result.to_json}"
    update_test_rails = update_test_results(tr_client, test_tid, JSON.parse(@result.to_json))
    puts "Updated Test Rails: #{update_test_rails}"
    # TestRail::SlackNotification.new('kofrankie', test_rail_run_name, test_run_id, test_tid, !any_failed_steps).post_slack_notification
  end

  def test_rail_expected_steps(expected_steps)
    @result[:expected_steps] = expected_steps
  end

  def test_rail_expected_result(step_number, expected)
    step = "Step#{step_number}"

    step_already_exists = @result[:custom_step_results].find do |step_name|
      step_name[:content] == step
    end

    if step_already_exists.nil?
      @result[:custom_step_results] << { content: step, expected: expected }
    else
      step_already_exists[:expected] = step_already_exists[:expected].to_s + "\n\n #{expected}"
    end
  end

  def test_rail_result(step_number, actual, step_pass_fail = '')
    step = "Step#{step_number}"

    case step_pass_fail.downcase
    when "pass"
      status = 1 #pass
    when "fail"
      status = 5 #fail
    else
      status = ''
    end

    #combine with existing step if one already exists
    step_already_exists = @result[:custom_step_results].find do |step_name|
      step_name[:content] == step
    end
    if step_already_exists.nil?
      @result[:custom_step_results] << { content: step, actual: actual, status_id: status }
    else
      step_already_exists[:actual] = step_already_exists[:actual].to_s + "\n\n #{actual}"
      unless step_already_exists[:status_id] == 5 || status.to_s.empty?
        step_already_exists[:status_id] = status
      end
    end

  end

end


