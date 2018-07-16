
module SmartTable
  module SmartTableConcern
    extend ActiveSupport::Concern

    included do
      helper_method :get_cached_smart_table_params
    end

    class Params
      attr_accessor :sort, :page_size, :page_number, :search

      def initialize
        self.sort = nil
        self.page_size = nil
        self.page_number = 1
        self.search = nil
      end

      def limit
        page_size
      end

      def offset
        page_size * (page_number-1) if page_size
      end
    end

    def smart_table_params(initial_page_size: 25)
      return @st_params if @st_params

      @st_params = Params.new
      @st_params.sort = params[SORT_PARAM]
      @st_params.search = params[SEARCH_PARAM]
      @st_params.page_size = params[PAGE_SIZE_PARAM] || initial_page_size
      if @st_params.page_size == SHOW_ALL
        @st_params.page_size = nil
      else
        @st_params.page_size = @st_params.page_size.to_i

        if params[PAGE_PARAM].present? && params[PAGE_PARAM] =~ /\d+/
          page = params[PAGE_PARAM].to_i
          page = 1 if page < 1
          @st_params.page_number = page
        end
      end

      @st_params
    end

  private

    def get_cached_smart_table_params
      @st_params
    end

  end
end
