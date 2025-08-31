# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "mcp"

# Test validation functionality
puts "=== Testing Argument Validation ==="

# Create an enum argument
language_arg = MCP::Prompt::Argument.enum(
  name: "language",
  enum_values: ["python", "javascript", "ruby"],
  description: "Programming language"
)

puts "Language argument created: #{language_arg.name}"
puts "Enum values: #{language_arg.enum_values}"
puts "Is enum? #{language_arg.enum?}"

# Test valid value
begin
  language_arg.validate_value("python")
  puts "✓ Valid value 'python' passed validation"
rescue => e
  puts "✗ Valid value 'python' failed validation: #{e.message}"
end

# Test invalid value
begin
  language_arg.validate_value("java")
  puts "✗ Invalid value 'java' should have failed validation"
rescue => e
  puts "✓ Invalid value 'java' correctly failed validation: #{e.message}"
end

# Test number argument with constraints
number_arg = MCP::Prompt::Argument.number(
  name: "temperature",
  minimum: 0.0,
  maximum: 1.0
)

puts "\nNumber argument created: #{number_arg.name}"

# Test valid number
begin
  number_arg.validate_value(0.5)
  puts "✓ Valid number 0.5 passed validation"
rescue => e
  puts "✗ Valid number 0.5 failed validation: #{e.message}"
end

# Test invalid number (too high)
begin
  number_arg.validate_value(1.5)
  puts "✗ Invalid number 1.5 should have failed validation"
rescue => e
  puts "✓ Invalid number 1.5 correctly failed validation: #{e.message}"
end

# Test string argument with length constraints
string_arg = MCP::Prompt::Argument.string(
  name: "code",
  min_length: 1,
  max_length: 100
)

puts "\nString argument created: #{string_arg.name}"

# Test valid string
begin
  string_arg.validate_value("def hello(): print('world')")
  puts "✓ Valid string passed validation"
rescue => e
  puts "✗ Valid string failed validation: #{e.message}"
end

# Test invalid string (too long)
begin
  long_string = "x" * 150
  string_arg.validate_value(long_string)
  puts "✗ Invalid string should have failed validation"
rescue => e
  puts "✓ Invalid string correctly failed validation: #{e.message}"
end

puts "\n=== All validation tests completed ==="
