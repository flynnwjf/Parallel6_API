
module TestRail
  class SlackNotification
    def payload
      @payload ||= JSON.parse(<<-JSON)
        {
            "attachments": [
                {
                    "fallback": "TestRails Notification",
                    "color": "#{color}",
                    "pretext": "TestRails Notification",
                    "title": "Automation: P6 - mClinical",
                    "author_name": "#{author_name}",
                    "author_link": "#{author_link}",
                    "fields": [
                        {
                            "title": "Test Run Result: #{test_result}",
                            "short": true
                        }
                    ],
                    "actions": [
                        {
                            "type": "button",
                            "name": "test",
                            "text": "Test ID: #{test_id}",
                            "url": "#{test_url}",
                            "style": "secondary"
                        },
                        {
                            "type": "button",
                            "name": "test_case",
                            "text": "Test Case ID: #{test_case_id}",
                            "url": "#{test_case_url}",
                            "style": "secondary"
                        }
                    ],
                    "footer": "TestRails",
                    "footer_icon": "https://static.testrail.io/5.5.1.3746/images/favicon.ico",
                    "ts": "#{timestamp}"
                }
            ]
        }
      JSON
    end
    attr_reader :author_name, :author_link, :test_run, :test_id, :test_url, :test_case_id, :test_case_url, :test_result, :color, :timestamp
    def initialize(author_name, test_run, test_id, test_case_id, test_result)
      @author_name = author_name
      @author_link = "https://parallel6.atlassian.net/wiki/display/~#{author_name}"
      @test_run = test_run
      @test_id = test_id
      @test_url = "https://parallel6.testrail.com/index.php?/runs/view/#{test_id}"
      @test_case_id = test_case_id
      @test_case_url = "https://parallel6.testrail.com/index.php?/tests/view/#{test_case_id}"
      @test_result = test_result ? 'PASS' : 'FAIL'
      @color = test_result ? 'good' : 'danger'
      @timestamp = Time.now.to_i
    end
    def post_slack_notification
      RestClient.post("https://hooks.slack.com/services/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",
                      payload.to_json, { content_type: :json })
    end
  end
end