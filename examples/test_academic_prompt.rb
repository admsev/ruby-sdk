# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "mcp"

# Test the AcademicProgressWorkloadPrompt
class AcademicProgressWorkloadPrompt < MCP::Prompt
  prompt_name "student_report_prompt" # Optional - defaults to underscored class name
  # title "Student Report Prompt" # WARNING: This is a `Draft` and is not supported in the `Version 2025-06-18 (latest)` specification.
  description "This prompt collects all the information for a student and generates a report"
  arguments [
    MCP::Prompt::Argument.enum(
      name:        "group_by",
      enum_values: %w(subject subject_group),
      enum_names:  ['Subject', 'Subject Group'],
      description: "How to group the data",
      required:    true
    ),
    MCP::Prompt::Argument.enum(
      name:        "year",
      enum_values: %w(2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030),
      enum_names:  %w(2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030),
      description: "4 digits",
      required:    true
    )
  ]

  class << self
    def template(args, server_context:)
      MCP::Prompt::Result.new(
        description: "Academic Progress Workload Report (chart data)",
        messages:    [
          MCP::Prompt::Message.new(
            role:    "user",
            content: MCP::Content::Text.new(<<~PROMPT)
              Get Academic Progress workload report grouped by #{args[:group_by]} for the year #{args[:year]}
            PROMPT
          )
          # MCP::Prompt::Message.new(
          #   role:    "assistant",
          #   content: MCP::Content::Text.new(args["message"])
          # )
        ]
      )
    end
  end
end

puts "=== Testing AcademicProgressWorkloadPrompt ==="

# Test the prompt definition
puts "\nPrompt definition:"
puts JSON.pretty_generate(AcademicProgressWorkloadPrompt.to_h)

# Test argument validation
puts "\n=== Testing Argument Validation ==="

group_by_arg = AcademicProgressWorkloadPrompt.arguments_value.find { |arg| arg.name == "group_by" }
year_arg = AcademicProgressWorkloadPrompt.arguments_value.find { |arg| arg.name == "year" }

puts "Group by argument:"
puts "  Name: #{group_by_arg.name}"
puts "  Enum values: #{group_by_arg.enum_values}"
puts "  Enum names: #{group_by_arg.enum_names}"
puts "  Is enum? #{group_by_arg.enum?}"

puts "\nYear argument:"
puts "  Name: #{year_arg.name}"
puts "  Enum values: #{year_arg.enum_values}"
puts "  Enum names: #{year_arg.enum_names}"
puts "  Is enum? #{year_arg.enum?}"

# Test valid values
puts "\n=== Testing Valid Values ==="
begin
  group_by_arg.validate_value("subject")
  puts "✓ Valid group_by value 'subject' passed validation"
rescue => e
  puts "✗ Valid group_by value 'subject' failed validation: #{e.message}"
end

begin
  year_arg.validate_value("2024")
  puts "✓ Valid year value '2024' passed validation"
rescue => e
  puts "✗ Valid year value '2024' failed validation: #{e.message}"
end

# Test invalid values
puts "\n=== Testing Invalid Values ==="
begin
  group_by_arg.validate_value("invalid_group")
  puts "✗ Invalid group_by value 'invalid_group' should have failed validation"
rescue => e
  puts "✓ Invalid group_by value 'invalid_group' correctly failed validation: #{e.message}"
end

begin
  year_arg.validate_value("2019")
  puts "✗ Invalid year value '2019' should have failed validation"
rescue => e
  puts "✓ Invalid year value '2019' correctly failed validation: #{e.message}"
end

# Test template execution
puts "\n=== Testing Template Execution ==="
begin
  result = AcademicProgressWorkloadPrompt.template(
    { group_by: "subject", year: "2024" },
    server_context: nil
  )
  puts "✓ Template execution successful"
  puts "Description: #{result.description}"
  puts "Messages count: #{result.messages.length}"
  puts "First message content: #{result.messages.first.content.text}"
rescue => e
  puts "✗ Template execution failed: #{e.message}"
  puts e.backtrace.first(3)
end

puts "\n=== Test completed ==="
