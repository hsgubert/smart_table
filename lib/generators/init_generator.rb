require 'rails/generators'

# Generates gem initializer
#
#   rails g smart_table:init
#

module SmartTable
  class InitGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer
      copy_file 'smart_table_initializer.rb', 'config/initializers/smart_table.rb'
    end
  end
end
