# typed: strict
# frozen_string_literal: true

require "json-schema"

module MCP
  class Prompt
    class Argument
      class ValidationError < StandardError; end

      attr_reader :name, :description, :required, :title, :schema

      def initialize(name:, description: nil, required: false, title: nil, schema: nil)
        @name = name
        @description = description
        @required = required
        @title = title
        @schema = schema || { type: "string" }
        validate_schema!
      end

      # Convenience method for creating enum arguments
      def self.enum(name:, enum_values:, enum_names: nil, description: nil, required: false, title: nil)
        # Convert enum values to strings to ensure consistent validation
        string_enum_values = enum_values.map(&:to_s)
        string_enum_names = enum_names&.map(&:to_s) if enum_names

        schema = {
          "type" => "string",
          "enum" => string_enum_values
        }
        schema["enumNames"] = string_enum_names if string_enum_names

        new(
          name: name,
          description: description,
          required: required,
          title: title,
          schema: schema
        )
      end

      # Convenience method for creating string arguments
      def self.string(name:, description: nil, required: false, title: nil, format: nil, min_length: nil, max_length: nil)
        schema = { "type" => "string" }
        schema["format"] = format if format
        schema["minLength"] = min_length if min_length
        schema["maxLength"] = max_length if max_length

        new(
          name: name,
          description: description,
          required: required,
          title: title,
          schema: schema
        )
      end

      # Convenience method for creating number arguments
      def self.number(name:, description: nil, required: false, title: nil, minimum: nil, maximum: nil)
        schema = { "type" => "number" }
        schema["minimum"] = minimum if minimum
        schema["maximum"] = maximum if maximum

        new(
          name: name,
          description: description,
          required: required,
          title: title,
          schema: schema
        )
      end

      # Convenience method for creating integer arguments
      def self.integer(name:, description: nil, required: false, title: nil, minimum: nil, maximum: nil)
        schema = { "type" => "integer" }
        schema["minimum"] = minimum if minimum
        schema["maximum"] = maximum if maximum

        new(
          name: name,
          description: description,
          required: required,
          title: title,
          schema: schema
        )
      end

      # Convenience method for creating boolean arguments
      def self.boolean(name:, description: nil, required: false, title: nil)
        new(
          name: name,
          description: description,
          required: required,
          title: title,
          schema: { "type" => "boolean" }
        )
      end

      def to_h
        result = { name: name, required: required }
        result[:description] = description if description
        result[:title] = title if title

        # Include schema information if it's not just a basic string type
        if schema && schema != { "type" => "string" }
          result.merge!(schema)
        end

        result.compact
      end

      def validate_value(value)
        # For enum arguments, use custom validation to avoid JSON::Validator type issues
        if enum?
          validation_value = value.to_s
          unless enum_values.include?(validation_value)
            raise ValidationError, "Invalid value for argument '#{name}': '#{validation_value}' is not one of the allowed values: #{enum_values.join(', ')}"
          end
          return true
        end

        # For non-enum arguments, use JSON::Validator
        errors = JSON::Validator.fully_validate(schema, value)
        if errors.any?
          raise ValidationError, "Invalid value for argument '#{name}': #{errors.join(", ")}"
        end
        true
      end

      def enum?
        schema["enum"] && schema["type"] == "string"
      end

      def enum_values
        schema["enum"] if enum?
      end

      def enum_names
        schema["enumNames"] if enum?
      end

      private

      def validate_schema!
        return unless schema

        # Check for $ref which is not allowed in prompt argument schemas
        check_for_refs!(schema)

        # Validate the schema against JSON Schema
        schema_reader = JSON::Schema::Reader.new(
          accept_uri: false,
          accept_file: ->(path) { path.to_s.start_with?(Gem.loaded_specs["json-schema"].full_gem_path) },
        )
        metaschema = JSON::Validator.validator_for_name("draft4").metaschema
        errors = JSON::Validator.fully_validate(metaschema, schema, schema_reader: schema_reader)
        if errors.any?
          raise ArgumentError, "Invalid JSON Schema for argument '#{name}': #{errors.join(", ")}"
        end
      end

      def check_for_refs!(obj)
        case obj
        when Hash
          if obj.key?("$ref") || obj.key?(:$ref)
            raise ArgumentError, "Invalid JSON Schema: $ref is not allowed in prompt argument schemas"
          end

          obj.each_value { |value| check_for_refs!(value) }
        when Array
          obj.each { |item| check_for_refs!(item) }
        end
      end
    end
  end
end
