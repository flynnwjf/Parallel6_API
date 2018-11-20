# class TestRailsFormatter
#   RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed
#
#   def initialize(out)
#     @out = out
#   end
#
#   def example_finished(notification)
#     example = notification.example
#     @out.puts "finishing up test: #{example.metadata[:description]}"
#     result = example.execution_result
#     @out.puts "   result #{result.inspect}"
#     stat = result.status
#     @out.puts "   result status #{stat}"
#     @out.puts "   result test_name = #{example.metadata[:test_name]}, section = #{example.metadata[:section]}, other = #{example.metadata[:other]}"
#   end
#
#   alias example_passed example_finished
#   alias example_pending example_finished
#   alias example_failed example_finished
# end