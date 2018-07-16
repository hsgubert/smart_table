require_relative '../../../../rails_helper.rb'

RSpec.describe SmartTable::SmartTableConcern do

  before do
    @params = HashWithIndifferentAccess.new
    controller.instance_variable_set(:@params, @params)
    controller.define_singleton_method(:params) do
      @params
    end
  end

  # makes helper available through `controller`
  let(:controller) do
    klass = Class.new
    klass.extend SmartTable::SmartTableConcern
    klass
  end

  describe '#smart_table_params' do
    it 'initializes parameters on first call' do
      smart_table_params = controller.smart_table_params
      expect(smart_table_params.sort).to be_nil
      expect(smart_table_params.search).to be_nil
      expect(smart_table_params.page_number).to be == 1
      expect(smart_table_params.page_size).to be == 25
      expect(smart_table_params.limit).to be == 25
      expect(smart_table_params.offset).to be == 0
    end

    it 'allows user to specify initial page size' do
      smart_table_params = controller.smart_table_params(initial_page_size: 10)
      expect(smart_table_params.sort).to be_nil
      expect(smart_table_params.search).to be_nil
      expect(smart_table_params.page_number).to be == 1
      expect(smart_table_params.page_size).to be == 10
      expect(smart_table_params.limit).to be == 10
      expect(smart_table_params.offset).to be == 0
    end

    it 'considers st_page parameter to choose the page_number' do
      @params[:st_page] = '2'

      smart_table_params = controller.smart_table_params(initial_page_size: 10)
      expect(smart_table_params.sort).to be_nil
      expect(smart_table_params.search).to be_nil
      expect(smart_table_params.page_number).to be == 2
      expect(smart_table_params.page_size).to be == 10
      expect(smart_table_params.limit).to be == 10
      expect(smart_table_params.offset).to be == 10
    end

    it 'considers st_page_size parameter to choose the page_size' do
      @params[:st_page] = '2'
      @params[:st_page_size] = '5'

      smart_table_params = controller.smart_table_params(initial_page_size: 10)
      expect(smart_table_params.sort).to be_nil
      expect(smart_table_params.search).to be_nil
      expect(smart_table_params.page_number).to be == 2
      expect(smart_table_params.page_size).to be == 5
      expect(smart_table_params.limit).to be == 5
      expect(smart_table_params.offset).to be == 5
    end

    it 'allows st_page_size to be "show_all"' do
      @params[:st_page] = '2'
      @params[:st_page_size] = 'show_all'

      smart_table_params = controller.smart_table_params(initial_page_size: 10)
      expect(smart_table_params.sort).to be_nil
      expect(smart_table_params.search).to be_nil
      expect(smart_table_params.page_number).to be == 1
      expect(smart_table_params.page_size).to be_nil
      expect(smart_table_params.limit).to be_nil
      expect(smart_table_params.offset).to be_nil
    end

    it 'considers st_sort parameter to populate sort attribute' do
      @params[:st_sort] = 'attribute DESC'

      smart_table_params = controller.smart_table_params
      expect(smart_table_params.sort).to be == 'attribute DESC'
      expect(smart_table_params.search).to be_nil
      expect(smart_table_params.page_number).to be == 1
      expect(smart_table_params.page_size).to be == 25
      expect(smart_table_params.limit).to be == 25
      expect(smart_table_params.offset).to be == 0
    end

    it 'considers st_search parameter to populate search attribute' do
      @params[:st_search] = 'somestring'

      smart_table_params = controller.smart_table_params
      expect(smart_table_params.sort).to be_nil
      expect(smart_table_params.search).to be == 'somestring'
      expect(smart_table_params.page_number).to be == 1
      expect(smart_table_params.page_size).to be == 25
      expect(smart_table_params.limit).to be == 25
      expect(smart_table_params.offset).to be == 0
    end
  end

end
