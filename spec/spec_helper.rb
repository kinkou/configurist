# frozen_string_literal: true

ENV['CONFIGURIST_AUTOLOAD'] = 'false' # Do not load schemas
require 'configurist'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'shoulda-matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :active_record
    with.library :active_model
  end
end

ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.logger.level = ENV.fetch('LOG_LEVEL', 'WARN')
