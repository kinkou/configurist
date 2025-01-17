# frozen_string_literal: true

RSpec.describe Configurist::Validator do
  let(:schema) do
    YAML.load_file(
      Configurist::SchemaFilesLocator.new.call.first
    )
  end

  describe '#validate_schema' do
    let(:perform) { described_class.new.validate_schema(schema:) }

    context 'when schema is valid' do
      it 'validates schema' do
        expect(perform).to eq([])
      end
    end

    context 'when schema is invalid' do
      let(:schema) { { '$id' => '#invalid' } }

      it 'returns an array of error messages' do
        expect(perform).to eq(['string at `/$id` does not match pattern: ^[^#]*#?$'])
      end
    end
  end

  describe '#validate_data' do
    let(:perform) { described_class.new.validate_data(data:, schema:) }

    let(:data) do
      {
        'settings_group' => {
          'subschema_setting' => {
            'property_name' => value
          }
        }
      }
    end

    context 'when data is valid' do
      let(:value) { 'value' }

      it 'validates data and returns no errors' do
        expect(perform).to eq([])
      end
    end

    context 'when data is invalid' do
      let(:value) { '' }

      it 'validates data and returns no errors' do
        expect(perform).to(
          eq(
            ['string length at `/settings_group/subschema_setting/property_name` is less than: 1']
          )
        )
      end
    end
  end
end
