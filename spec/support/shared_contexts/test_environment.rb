# frozen_string_literal: true

RSpec.shared_context 'with test environment' do
  let(:establish_db_connection) do
    ActiveRecord::Base.establish_connection(
      {
        adapter: 'postgresql',
        database: 'configurist_test',
        host: '127.0.0.1',
        port: '5432',
        username: 'postgres',
        password: 'password',
        min_messages: 'WARNING'
      }
    )
  end

  let(:create_configurables_table) do
    ActiveRecord::Base.connection.create_table(:configurables)
  end

  let(:drop_configurables_table) do
    ActiveRecord::Base.connection.drop_table(:configurables, force: true, if_exists: true)
  end

  let(:create_configurable_model) do
    stub_const('Configurable', Class.new(ActiveRecord::Base))

    Configurable.has_configurist_settings
  end

  let(:create_configurist_settings_table) do
    ActiveRecord::Base.connection.create_table(:configurist_settings) do |t|
      t.string(
        'ancestry',
        collation: 'C',
        null: (Ancestry.default_ancestry_format == :materialized_path),
        index: { name: 'ancestry' }
      )

      t.belongs_to :configurable, polymorphic: true, index: false
      t.string :scope, null: false
      t.jsonb :data, null: false, default: {}
      t.timestamps

      t.index %i[scope configurable_id configurable_type], unique: true
    end
  end

  let(:drop_configurist_settings_table) do
    ActiveRecord::Base.connection.drop_table(:configurist_settings, force: true, if_exists: true)
  end
end
