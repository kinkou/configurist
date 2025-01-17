# frozen_string_literal: true

module Configurist
  class Validator
    def validate_schema(schema:)
      JSONSchemer.validate_schema(schema).pluck('error')
    end

    def validate_data(data:, schema:)
      JSONSchemer.schema(schema).validate(data).pluck('error')
    end
  end
end
