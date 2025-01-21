# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/hash/indifferent_access'
require 'ancestry'
require 'json_schemer'

# Configurist gem's own settings
module Configurist
  # Store loaded schemas here
  mattr_accessor :schemas
  self.schemas = ActiveSupport::HashWithIndifferentAccess.new
end

require 'configurist/version'
require 'configurist/schema_files_locator'
require 'configurist/validators/schema'
require 'configurist/schema_loader'
require 'configurist/concerns/configurable'
require 'configurist/activate'

if ENV.fetch('CONFIGURIST_AUTOLOAD', 'true') == 'true'
  ActiveSupport.on_load(:active_record) do |active_record_base|
    Configurist::Activate.new.call(base: active_record_base)
  end
end

require 'configurist/models/settings' # Inheriting from ActiveRecord::Base will run the ActiveSupport.on_load hook
