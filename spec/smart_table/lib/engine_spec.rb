require_relative '../../spec_helper.rb'

RSpec.describe SmartTable::Engine do

  describe 'initializers' do
    it 'defines solvis_auth initializers' do
      engine = SmartTable::Engine.send(:new)
      expect(engine.initializers.last.name).to be == 'smart_table.action_controller'
    end
  end

end
