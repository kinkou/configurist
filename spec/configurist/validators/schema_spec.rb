# frozen_string_literal: true

RSpec.describe Configurist::Validators::Schema do
  let(:gem_test_schema) do
    YAML.load_file(
      Configurist::SchemaFilesLocator.new.call.first
    )
  end
  let(:schema) { gem_test_schema }

  describe '#validate_schema' do
    let(:perform) { described_class.new.validate_schema(schema:) }

    context 'when schema is valid' do
      it 'validates schema' do
        expect(perform).to eq([])
      end
    end

    context 'when schema violates the standard' do
      let(:schema) { { 'type' => 'object', '$id' => '#invalid' } }

      it 'returns an array of error messages' do
        expect(perform).to eq(['string at `/$id` does not match pattern: ^[^#]*#?$'])
      end
    end

    context 'when schema defines settings not as object' do
      let(:schema) { { 'type' => %w[string number integer array boolean null].sample } }

      it 'does not pass validation' do
        expect(perform).to eq(['settings must be an object'])
      end
    end
  end

  describe '#insert_defaults' do
    let(:perform) { described_class.new.insert_defaults(data:, schema:) }

    let(:data) do
      { settings_group: { simple_string_setting: 'string', subschema_setting: { property_name: 'string' } } }
    end

    it 'inserts them into data if they are present in schema' do
      expect(perform.dig(:settings_group, :simple_number_setting)).to eq(3.14)
    end

    it 'returns ActiveSupport::HashWithIndifferentAccess' do
      expect(perform.class.name).to eq('ActiveSupport::HashWithIndifferentAccess')
    end
  end

  describe '#validate_defaults' do
    let(:perform) { described_class.new.validate_defaults(data:, schema:) }

    describe 'making all properties required' do
      context 'when data is empty' do
        let(:data) { {} }

        specify do
          expect(perform).to eq(['object at root is missing required properties: settings_group'])
        end
      end

      context 'when settings_group added' do
        let(:data) { { settings_group: {} } }

        specify do
          expect(perform).to(
            eq(['object at `/settings_group` is missing required properties: simple_string_setting, subschema_setting'])
          )
        end
      end

      context 'when simple_string_setting added' do
        let(:data) { { settings_group: { simple_string_setting: 'string' } } }

        specify do
          expect(perform).to(
            eq(['object at `/settings_group` is missing required properties: subschema_setting'])
          )
        end
      end

      context 'when subschema_setting added' do
        let(:data) { { settings_group: { simple_string_setting: 'string', subschema_setting: {} } } }

        specify do
          expect(perform).to(
            eq(['object at `/settings_group/subschema_setting` is missing required properties: property_name'])
          )
        end
      end

      context 'when property_name added' do
        let(:data) do
          { settings_group: { simple_string_setting: 'string', subschema_setting: { property_name: 'string' } } }
        end

        specify { expect(perform).to eq([]) }
      end
    end

    describe 'defaults data validation' do
      let(:data) do
        { settings_group: { simple_string_setting: 'string', subschema_setting: { property_name: true } } }
      end

      it 'validates' do
        expect(perform).to(
          eq(['value at `/settings_group/subschema_setting/property_name` is not a string'])
        )
      end
    end
  end

  describe '#validate_overrides' do
    let(:perform) { described_class.new.validate_overrides(data:, schema:) }

    let(:data) do
      {
        'settings_group' => {
          'simple_number_setting' => value
        }
      }
    end

    context 'when data is valid' do
      let(:value) { 1.23 }

      it 'validates data and returns no errors' do
        expect(perform).to eq([])
      end
    end

    context 'when data is invalid' do
      let(:value) { '1.23' }

      it 'validates data and returns no errors' do
        expect(perform).to(
          eq(['value at `/settings_group/simple_number_setting` is not a number'])
        )
      end
    end
  end
end
