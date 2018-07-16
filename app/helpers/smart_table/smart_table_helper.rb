module SmartTable
  module SmartTableHelper

    # Renders pagination controls (centered, usually below the table). Usage:
    #
    #   <%= smart_table_paginate @records, @total_records_count, Record.model_name.human %>
    #
    # This method requires the loaded records for the current page and the total
    # record count (sum of all pages). It also requires the listed record's human
    # name, so it can generate a human sentence for the number of records shown.
    #
    # When the user clicks on one of the page size's links, a new request to the
    # index action is made, including a page number parameter available through
    # smart_table_params.limit and smart_table_params.offset.
    #
    # These values can be passed to ActiveRecord directly, e.g.:
    #
    #   @records = Record.
    #     limit(smart_table_params.limit).
    #     offset(smart_table_params.offset)

    def smart_table_paginate(records, total_records_count, record_model_name)
      raise 'smart_table_params must be called on the controller, before using smart_table_paginate helper' unless get_cached_smart_table_params

      paginatable_array = Kaminari.
        paginate_array(records, total_count: total_records_count).
        page(get_cached_smart_table_params.page_number).
        per(get_cached_smart_table_params.page_size)

      html_elements = []

      # call to Kaminari view helper
      html_elements << paginate(paginatable_array, param_name: PAGE_PARAM, theme: "smart_table")

      html_elements << content_tag(:div, class: 'text-center') do
        # call to Kaminari view helper
        page_entries_info(paginatable_array, entry_name: record_model_name.downcase)
      end

      html_elements.join.html_safe
    end

    SORT_ORDERS = ["asc", "desc"]

    # Renders table header with sortable feature. Usage:
    #
    #   <th><%= smart_table_sortable("Header Text", :attribute_name) %></th>
    #
    # This will generate a link that will make a new request to your index page,
    # including a sort parameter that will be available through smart_table_params.sort.
    # You can simply pass this parameter to ActiveRecord:
    #
    #   @records = Record.order(smart_table_params.sort)

    def smart_table_sortable(text, attribute)
      raise 'smart_table_params must be called on the controller, before using smart_table_sortable helper' unless get_cached_smart_table_params

      current_sort_state = get_cached_smart_table_params.sort
      attribute = attribute.to_s

      current_sort_attribute, current_sort_order = if current_sort_state.present?
        current_sort_state.downcase.split
      else
        nil
      end

      next_sort_order = if current_sort_attribute == attribute
        SORT_ORDERS[(SORT_ORDERS.index(current_sort_order) + 1) % SORT_ORDERS.size]
      else
        SORT_ORDERS.first
      end

      link_url = current_request_url_with_merged_query_params(SORT_PARAM => "#{attribute} #{next_sort_order}")
      link_to link_url do
        text.html_safe + ' ' + (
          if current_sort_attribute == attribute && current_sort_order == 'asc'
            "<span class='fa fa-sort-down'></span>".html_safe
          elsif current_sort_attribute == attribute && current_sort_order == 'desc'
            "<span class='fa fa-sort-up'></span>".html_safe
          else
            "<span class='fa fa-sort'></span>".html_safe
          end
        )
      end
    end

    # Renders table page size selector (centered, usually below the table). Usage:
    #
    #   <%= smart_table_page_size_selector @total_records_count, Record.model_name.human %>
    #
    # This method requires the total number of records, so it can prune the list
    # of available page size to only the ones that make sense for a certain
    # number of records. It also requires the listed record's human name, so
    # it can generate a human sentence for the number of records shown.
    #
    # When the user clicks on one of the page size's links, a new request to the
    # index action is made, including a page size parameter available through
    # smart_table_params.limit and smart_table_params.offset.
    #
    # These values can be passed to ActiveRecord directly, e.g.:
    #
    #   @records = Record.
    #     limit(smart_table_params.limit).
    #     offset(smart_table_params.offset)


    def smart_table_page_size_selector(total_records_count, record_model_name)
      raise 'smart_table_params must be called on the controller, before using smart_table_page_size_selector helper' unless get_cached_smart_table_params

      page_sizes = PAGE_SIZES.dup
      page_sizes << get_cached_smart_table_params.page_size.to_i if get_cached_smart_table_params.page_size
      page_sizes.sort!

      if page_sizes.last >= total_records_count || get_cached_smart_table_params.page_size.nil?
        page_sizes.reject! {|size| size > total_records_count}
        page_sizes << SHOW_ALL
      end

      content_tag(:div, class: 'text-center') do
        (
          record_model_name.pluralize + ' ' +
          I18n.t('smart_table.per_page') + ': ' +
          page_sizes.map do |page_size|
            if page_size == get_cached_smart_table_params.page_size
              page_size.to_s
            else
              human_page_size = (page_size == SHOW_ALL ? I18n.t('smart_table.show_all') : page_size.to_s)
              link_to human_page_size, current_request_url_with_merged_query_params(PAGE_SIZE_PARAM => page_size)
            end
          end.join(' ')
        ).html_safe
      end
    end

    # Renders search field (right-aligned, usually above the table). Usage:
    #
    #   <div>
    #     <%= smart_table_search %>
    #   </div>
    #
    #   <table class='table'>
    #     <thead>
    #       ...
    #
    # When the user types something on the search field and focuses out (or
    # presses ENTER), a new request is made to the index action, including a
    # search parameter available through smart_table_params.search.
    #
    # You are responsible for using the search parameter to build a query in your
    # own way e.g.:
    #
    #   @records = Record.
    #     where(
    #       'column1 LIKE ? OR column2 LIKE ?',
    #       *Array.new(2, "%#{ActiveRecord::Base.sanitize_sql_like(smart_table_params.search)}%")
    #     )

    def smart_table_search
      raise 'smart_table_params must be called on the controller, before using smart_table_search helper' unless get_cached_smart_table_params

      text_field_tag(
        SEARCH_PARAM,
        get_cached_smart_table_params.search,
        type: 'search', placeholder: I18n.t('smart_table.search'), class: 'smart_table_search', id: 'smart_table_search'
      )
    end

    # Creates section for extra table filters. Usage:
    #
    # <%= smart_table_extra_filters do %>
    #   <%= check_box_tag 'somekey', 'value', params['somekey'] %>
    #   <%= select_tag "credit_card", options_for_select({"VISA" => 'visa', "MasterCard" => 'master_card'}, params['credit_card']) %>
    #   <%= text_field_tag "somefield", params['somefield'] %>
    #   <%= radio_button_tag("category", "", !params["category"].present?) %>
    #   <%= radio_button_tag("category", "rails", params["category"] == 'rails') %>
    #   <%= radio_button_tag("category", "java", params["category"] == 'java') %>
    # <% end %>
    #
    # Everytime the user changes any of the fields inside this section, the page
    # will be refreshed and the field value will be included to the request params.
    #
    # You are responsible for using the parameters by yourself when loading the
    # records.

    def smart_table_extra_filters(&block)
      raise 'smart_table_params must be called on the controller, before using smart_table_extra_filters helper' unless get_cached_smart_table_params

      content = capture(&block)
      content_tag(:div,
        content,
        id: 'smart_table_extra_filters',
        class: 'smart_table_extra_filters'
      )
    end

  private

    # generates url merging parameters to the current url
    def current_request_url_with_merged_query_params(params)
      request_url = URI::parse(request.url)
      link_query_params = URI::decode_www_form(request_url.query || '').to_h.merge(params.stringify_keys)
      link_url = request_url.dup
      link_url.query = URI::encode_www_form(link_query_params)
      link_url.to_s
    end

  end
end
