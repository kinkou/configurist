# frozen_string_literal: true

module Configurist
  module Concerns
    module Configurable
      DEFAULT_OPTIONS = {
        dependent_records_behavior: :destroy,
        settings_method_name: :settings
      }.freeze

      def has_configurist_settings(user_options = {}) # rubocop:disable Naming/PredicateName
        resulting_options = DEFAULT_OPTIONS.merge(user_options)

        has_many(
          :configurist_settings,
          class_name: 'Configurist::Models::Settings',
          as: :configurable,
          dependent: resulting_options[:dependent_records_behavior]
        )

        define_method(resulting_options[:settings_method_name]) do |scope:|
          configurist_settings.where(scope:).pick(:data)
        end
      end
    end
  end
end
