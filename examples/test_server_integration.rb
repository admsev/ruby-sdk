# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "mcp"

# Create a prompt with enum arguments
class TestPrompt < MCP::Prompt
  description "A test prompt with enum arguments"
  arguments [
    MCP::Prompt::Argument.enum(
      name: "language",
      enum_values: ["python", "javascript", "ruby"],
      description: "Programming language",
      required: true
    ),
    MCP::Prompt::Argument.string(
      name: "code",
      description: "Code to process",
      required: true,
      max_length: 1000
    )
  ]

  class << self
    def template(args, server_context:)
      language = args[:language]
      code = args[:code]

      prompt_text = "Process this #{language} code:\n#{code}"

      MCP::Prompt::Result.new(
        messages: [
          MCP::Prompt::Message.new(
            role: "user",
            content: MCP::Content::Text.new(prompt_text),
          ),
        ],
      )
    end
  end
end

# Test server integration
puts "=== Testing Server Integration ==="

# Create server with the prompt
server = MCP::Server.new(
  name: "test_server",
  version: "1.0.0",
  prompts: [TestPrompt],
)

# Test prompt listing
puts "Prompt definition from server:"
prompt_def = TestPrompt.to_h
puts JSON.pretty_generate(prompt_def)

# Test argument validation
puts "\n=== Testing Argument Validation ==="

# Valid arguments
valid_args = {
  language: "python",
  code: "def hello(): print('world')"
}

begin
  TestPrompt.validate_arguments!(valid_args)
  puts "✓ Valid arguments passed validation"
rescue => e
  puts "✗ Valid arguments failed validation: #{e.message}"
end

# Test individual argument validation
puts "\n=== Testing Individual Argument Validation ==="

language_arg = TestPrompt.arguments_value.find { |arg| arg.name == "language" }

begin
  language_arg.validate_value("python")
  puts "✓ Valid language 'python' passed validation"
rescue => e
  puts "✗ Valid language 'python' failed validation: #{e.message}"
end

begin
  language_arg.validate_value("java")
  puts "✗ Invalid language 'java' should have failed validation"
rescue => e
  puts "✓ Invalid language 'java' correctly failed validation: #{e.message}"
end

# Test prompt execution
puts "\n=== Testing Prompt Execution ==="

begin
  result = TestPrompt.template(valid_args, server_context: {})
  puts "✓ Prompt execution successful"
  puts "Generated message: #{result.messages.first.content.text}"
rescue => e
  puts "✗ Prompt execution failed: #{e.message}"
end

puts "\n=== Server Integration Test Completed ==="
