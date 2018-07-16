require_relative '../../../rails_helper.rb'

RSpec.describe SmartTable::SmartTableHelper do

  before do
    # this helper requires access to the get_cached_smart_table_params method,
    # which returns the current smart_table_params defined on the controller.
    # We initialize a default @smart_table_params with page_size=3
    @smart_table_params = SmartTable::SmartTableConcern::Params.new
    @smart_table_params.sort = nil
    @smart_table_params.page_size = 3
    @smart_table_params.page_number = 1
    @smart_table_params.search = nil
    helper.instance_variable_set(:@smart_table_params, @smart_table_params)
    helper.define_singleton_method(:get_cached_smart_table_params) do
      @smart_table_params
    end

    # Kaminari, which is a dependency of smart_table, requires access to params
    # inside its helpers. It reads the :st_page parameter to know what is the
    # current page, or it assumes it is the first page if no :st_page is found
    @params = HashWithIndifferentAccess.new
    helper.instance_variable_set(:@params, @params)
    helper.define_singleton_method(:params) do
      @params
    end

    @records = [1,2,3]
    @total_records_count = 8
    @record_model_name = 'User'
  end

  # makes helper available through `helper`
  let(:helper) do
    klass = Class.new
    klass.extend SmartTable::SmartTableHelper
    klass
  end

  describe '#smart_table_paginate' do
    pending 'returns pagination commands' do
      html = helper.smart_table_paginate(@records, @total_records_count, @record_model_name)

      # I was not able to make the helper render kaminari pagination
    end
  end

end
