# frozen_string_literal: true

RSpec.describe Configurist::SchemaFilesLocator do
  let(:perform) { described_class.new.call }

  context 'when Rails is defined' do
    let(:rails) { class_double('Rails', root: gem_schema_files_path) } # rubocop:disable RSpec/VerifiedDoubleReference

    before do
      stub_const('Rails', rails)
    end

    context 'when schema files are found' do
      let(:gem_schema_files_path) { Pathname.new(__dir__).join('../../') }

      it 'calls Rails.root' do
        perform

        expect(rails).to have_received(:root)
      end

      it 'returns an array of Pathname objects pointing to schema files', :aggregate_failures do
        expect(perform).to be_an(Array)
        expect(perform.first).to be_a(Pathname)
        expect(perform.first.extname).to eq('.yml')
      end

      it 'filters out directories with .yml extension', :aggregate_failures do
        expect(perform.size).to eq(1)
        expect(perform.first.basename.to_s).to eq('default.yml')
      end
    end

    context 'when no schema files are found' do
      let(:gem_schema_files_path) { Pathname.new(__dir__) }

      it 'raises an exception' do
        expect { perform }.to raise_error(described_class::Error)
      end
    end
  end

  context 'when Rails is not defined' do
    let(:gem_schema) { YAML.load_file(perform.first) }

    it 'uses test schema files from the gem' do
      expect(gem_schema['description']).to eq('Default scope schema for tests')
    end
  end
end
