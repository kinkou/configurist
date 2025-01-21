# frozen_string_literal: true

module Configurist
  class SchemaFilesLocator
    Error = Class.new(StandardError)

    SCHEMAS_LOCATION = 'config/configurist_schemas/**/*.yml'

    def call
      files = find_schema_files

      raise(Error, 'No schema files found') if files.empty?

      files.filter(&:file?)
    end

    private

    def find_schema_files
      return Rails.root.glob(SCHEMAS_LOCATION) if defined?(Rails)

      Pathname.new(__dir__).join('../../').glob(SCHEMAS_LOCATION) # For hand-testing locally without Rails
    end
  end
end
