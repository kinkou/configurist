# frozen_string_literal: true

module Configurist
  module Models
    # This is an ActiveRecord model that represents a setting (and not a place for Configurist gem's own settings)
    class Settings < ActiveRecord::Base
      self.table_name = 'configurist_settings'

      belongs_to(
        :configurable,
        polymorphic: true
      )

      has_ancestry

      validates :scope, inclusion: { in: -> { Configurist.schemas.keys } }
      validate :same_scope_parent

      private

      def same_scope_parent
        return if parent.nil?
        return if parent.scope.to_s == scope.to_s

        errors.add(:parent, 'must have the same scope')
      end
    end
  end
end
