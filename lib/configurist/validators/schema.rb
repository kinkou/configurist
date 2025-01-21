# frozen_string_literal: true

module Configurist
  module Validators
    class Schema
      Error = Class.new(StandardError)

      def validate_schema(schema:)
        errors = JSONSchemer.validate_schema(schema).pluck('error')
        errors << 'settings must be an object' if schema['type'] != 'object'

        errors
      end

      def validate_defaults(data:, schema:)
        data_with_defaults = data.deep_dup

        defaults_schema = make_all_props_required(source_schema: schema, target_schema: schema.deep_dup)

        errors = JSONSchemer
                 .schema(defaults_schema, insert_property_defaults: true)
                 .validate(data_with_defaults)
                 .pluck('error')

        ActiveSupport::HashWithIndifferentAccess.new({ data:, errors: })
      end

      def validate_overrides(data:, schema:)
        JSONSchemer.schema(schema).validate(data).pluck('error')
      end

      private

      # Takes a schema and its deep clone, recursively walks the original schema and adds `required`
      # to the copy, effectively making all settings required.
      #
      # Before:
      # properties:
      #   prop:
      #     type: 'string'
      #
      # After:
      # required: ['prop']
      # properties:
      #   prop:
      #     type: 'string'
      def make_all_props_required(source_schema:, target_schema:, path: [])
        source_schema.each do |key, value|
          next if !value.is_a?(Hash)

          properties = source_schema['properties']&.keys
          if properties.present?
            target_hash = path.any? ? target_schema.dig(*path) : target_schema
            target_hash['required'] = properties
          end

          path.push(key)
          make_all_props_required(source_schema: value, target_schema:, path:)
          path.pop
        end

        target_schema
      end
    end
  end
end
