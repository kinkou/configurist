# frozen_string_literal: true

module Configurist
  class Activate
    def call(base:)
      base.extend(Configurist::Concerns::Configurable)

      Configurist::SchemaLoader.new.call
    end
  end
end
