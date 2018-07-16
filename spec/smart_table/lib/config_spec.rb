require_relative '../../spec_helper.rb'

RSpec.describe SmartTable::Config do

  describe 'accessors and default values' do
    it 'should have accessors for all configurations, initialized with default values' do
      SmartTable::Config::DEFAULT_CONFIGS.each do |config_name, default_value|
        # test writter
        initial_value = described_class.send(config_name)
        expect(described_class.send(config_name.to_s + '=', 1435))
        expect(described_class.send(config_name)).to be == 1435

        # restores initial value
        expect(described_class.send(config_name.to_s + '=', initial_value))
      end
    end
  end
end
