require 'rails'
require 'kaminari'

require 'smart_table/engine' if defined?(Rails::Engine)

require 'smart_table/version'
require 'smart_table/config'
require 'generators/init_generator'


module SmartTable

  # Method called on the gem initializer
  def self.setup
    if block_given?
      yield Config
    end
  end

  # Constants
  SORT_PARAM = :st_sort
  PAGE_PARAM = :st_page
  PAGE_SIZE_PARAM = :st_page_size
  SEARCH_PARAM = :st_search
  SHOW_ALL = 'show_all'
  PAGE_SIZES = [10,50,200]

end
