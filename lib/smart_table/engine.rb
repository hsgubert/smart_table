
module SmartTable

  class Engine < ::Rails::Engine

    # This makes models, controllers and routes defined on this gem to be all
    # scoped under SmartTable::
    # Ref: http://edgeguides.rubyonrails.org/engines.html
    isolate_namespace SmartTable

    # This automatically includes smart_table methods on all controllers
    initializer 'smart_table.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        include SmartTable::SmartTableConcern
        helper SmartTable::SmartTableHelper
      end
    end

  end

end
