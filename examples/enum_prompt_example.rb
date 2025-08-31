# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "mcp"

# Example prompt with enum arguments
class CodeReviewPrompt < MCP::Prompt
  description "A prompt for code review with language and framework selection"
  arguments [
    MCP::Prompt::Argument.enum(
      name: "language",
      enum_values: ["python", "javascript", "ruby", "java", "go", "rust"],
      enum_names: ["Python", "JavaScript", "Ruby", "Java", "Go", "Rust"],
      description: "The programming language of the code to review",
      required: true
    ),
    MCP::Prompt::Argument.enum(
      name: "framework",
      enum_values: ["django", "flask", "express", "rails", "spring", "gin", "actix"],
      enum_names: ["Django", "Flask", "Express", "Rails", "Spring", "Gin", "Actix"],
      description: "The framework being used (optional)",
      required: false
    ),
    MCP::Prompt::Argument.string(
      name: "code",
      description: "The code to review",
      required: true,
      max_length: 10000
    ),
    MCP::Prompt::Argument.enum(
      name: "review_type",
      enum_values: ["security", "performance", "style", "comprehensive"],
      description: "Type of review to perform",
      required: false
    ),
    MCP::Prompt::Argument.boolean(
      name: "include_suggestions",
      description: "Whether to include code suggestions",
      required: false
    )
  ]

  class << self
    def template(args, server_context:)
      language = args[:language]
      framework = args[:framework]
      code = args[:code]
      review_type = args[:review_type] || "comprehensive"
      include_suggestions = args[:include_suggestions] || false

      prompt_text = "Please review this #{language} code"
      prompt_text += " using #{framework}" if framework
      prompt_text += " with a focus on #{review_type} aspects."
      prompt_text += " Include specific code suggestions." if include_suggestions
      prompt_text += "\n\nCode to review:\n#{code}"

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

# Example prompt with number arguments
class MathPrompt < MCP::Prompt
  description "A prompt for mathematical operations"
  arguments [
    MCP::Prompt::Argument.enum(
      name: "operation",
      enum_values: ["add", "subtract", "multiply", "divide", "power"],
      description: "The mathematical operation to perform",
      required: true
    ),
    MCP::Prompt::Argument.number(
      name: "a",
      description: "First number",
      required: true,
      minimum: -1000,
      maximum: 1000
    ),
    MCP::Prompt::Argument.number(
      name: "b",
      description: "Second number",
      required: true,
      minimum: -1000,
      maximum: 1000
    ),
    MCP::Prompt::Argument.boolean(
      name: "show_steps",
      description: "Show calculation steps",
      required: false
    )
  ]

  class << self
    def template(args, server_context:)
      operation = args[:operation]
      a = args[:a]
      b = args[:b]
      show_steps = args[:show_steps] || false

      prompt_text = "Perform the #{operation} operation on #{a} and #{b}"
      prompt_text += " and show the calculation steps." if show_steps

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

# Example of how to use the new enum arguments
if __FILE__ == $0
  puts "=== Code Review Prompt Example ==="
  code_review = CodeReviewPrompt.new

  # This would be the JSON representation sent to the client
  puts "Prompt definition:"
  puts JSON.pretty_generate(code_review.class.to_h)

  puts "\n=== Math Prompt Example ==="
  math_prompt = MathPrompt.new

  puts "Prompt definition:"
  puts JSON.pretty_generate(math_prompt.class.to_h)

  puts "\n=== Example Usage ==="
  puts "To use these prompts, you would call them like this:"
  puts "code_review.template({"
  puts "  language: 'python',"
  puts "  framework: 'django',"
  puts "  code: 'def hello(): print(\"world\")',"
  puts "  review_type: 'security',"
  puts "  include_suggestions: true"
  puts "})"
end
