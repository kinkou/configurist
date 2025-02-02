# frozen_string_literal: true

RSpec.describe Configurist::SchemaLoader do
  let(:perform) { described_class.new.call }

  before do
    Configurist.schemas = {}
  end

  it 'loads available schemas to Configurist.schemas', :aggregate_failures do
    expect(Configurist.schemas).to eq({})

    perform

    expect(Configurist.schemas.keys.size).to eq(1)
    expect(Configurist.schemas.dig('default', 'description')).to eq('Default scope schema for tests')
  end

  it 'completely reloads schemas on each call', :aggregate_failures do
    Configurist.schemas = { 'invalid' => 'data' }

    perform

    expect(Configurist.schemas).not_to eq({ 'invalid' => 'data' })
  end
end
