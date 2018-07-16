require_relative './spec_helper'

RSpec.describe SmartTable do
  it "has a version number" do
    expect(SmartTable::VERSION).not_to be nil
  end

  it 'loads engine' do
    expect(defined? SmartTable::Engine).to be_truthy
    expect(SmartTable::Engine.superclass).to be == Rails::Engine
  end

  it 'loads init generator' do
    expect(defined? SmartTable::InitGenerator).to be_truthy
    expect(SmartTable::InitGenerator.superclass).to be == Rails::Generators::Base
  end

  describe '.setup' do
    it 'receives a block and yields gem configuration' do
      SmartTable.setup do |config|
        expect(config).to be == SmartTable::Config
      end
    end
  end

end
