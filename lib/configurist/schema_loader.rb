# frozen_string_literal: true

module Configurist
  class SchemaLoader
    InvalidSchemaError = Class.new(StandardError)

    def call
      Configurist.schemas.clear

      schema_files.each do |schema_file|
        schema = YAML.load_file(schema_file)

        validate_schema!(schema:)

        schema_id = schema['$id']
        Configurist.schemas[schema_id] = schema
      end
    end

    private

    def schema_files
      Configurist::SchemaFilesLocator.new.call
    end

    def validate_schema!(schema:)
      error_messages = Configurist::Validator.new.validate_schema(schema:)
      return if error_messages.blank?

      raise(InvalidSchemaError, error_messages.join('; '))
    end
  end
end
