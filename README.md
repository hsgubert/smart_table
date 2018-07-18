# SmartTable

Implements tables with pagination and search for Rails, with server-side content loading.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'smart_table'
```

And then execute:
```
bundle
```

## Getting Started

### Including Assets
SmartTable uses both JS and CSS, that must be included in your app's asset pipeline.
```
// Add this to your application.js or vendor.js
//= require smart_table

// Add this to your application.scss or vendor.scss
// smart_table uses font-awesome for the sorting icons, so make sure you require
// font-awesome first
*= require font-awesome
*= require smart_table
```

### Setting up the Controller
Add this line to your index action:
```ruby
  def index
    smart_table_params = smart_table_params(initial_page_size: 20)

    ...
  end
```

You can now use the `smart_table_params` object to customize your record's loading and counting:
```ruby
  # smart_table_params.search => string typed by user on search box (might be nil or empty)
  # smart_table_params.sort => string in the format of 'attribute ASC' or 'attribute DESC' (might be nil if there is no sorting specified)
  # smart_table_params.limit => page size (nil if showing all records)
  # smart_table_params.offset => record offset based on page number (nil if showing all records)

  @current_page_records = Record.
    where('column1 LIKE ? OR column2 LIKE ?', *Array.new(2, "%#{ActiveRecord::Base.sanitize_sql_like(smart_table_params.search)}%")).
    order(smart_table_params.sort).
    limit(smart_table_params.limit).
    offset(smart_table_params.offset)

  # Besides loading the records of the current page, the smart_table gem requires you
  # to count the total number of records of the table, so it can build the pagination
  # controls properly. Any filtering applied to record loading must be applied to
  # counting as well.
  @total_records_count = Record.
    where('column1 LIKE ? OR column2 LIKE ?', *Array.new(2, "%#{ActiveRecord::Base.sanitize_sql_like(smart_table_params.search)}%")).
    count
```

You can also use the `smart_table_params` to load/count records from another source, like an API or a NoSQL database. It is all up to you!

### Setting up the View
Now in your view, use the following helpers to enhance your table:

```html
<h1>Users</h1>

<div>
  <%# Renders text field for searching %>
  <%= smart_table_search %>
</div>

<table class='table'>
  <thead>
    <tr>
      <th></th>
      <th><%= smart_table_sortable("Username", :username) %></th>
      <th><%= smart_table_sortable("Email", :email) %></th>
      <th><%= smart_table_sortable("Name", :name) %></th>
      <th><%= User.human_attribute_name(:account_type) %></th> <%# this column is not sortable %>
    </tr>
  </thead>
  <tbody>
    <% @current_page_users.each do |user| %>
      <tr>
        <td><%= link_to "show", user_path(user) %></td>
        <td><%= user.username %></td>
        <td><%= user.email %></td>
        <td><%= user.name %></td>
        <td><%= user.account_type %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<%# Renders pagination controls (page numbers, previous/next buttons, etc) %>
<%# Requires both the records of the current page (@users) and the total count %>
<%= smart_table_paginate @current_page_users, @total_users_count, User.model_name.human %>

<%# Renders page size selector (depends on total record count) %>
<%= smart_table_page_size_selector @total_user_count, User.model_name.human %>
```

This should be enough for your smart table to function properly.

### Adding Extra Filters

Sometimes a single search box is not enough. You want to provide users more advanced filtering options. In this case you can use the `smart_table_extra_filters` helpers to wrap a set of fields, that will automatically trigger a a page refresh when changed, including the field value itself in the `params` hash.

You must handle the `params` hash by yourself in the controller (you will probably change the way you load your records, based on those parameters).

The following snippet shows how to use different input types to make custom filters.

```
<%# Renders text field for searching %>
<%= smart_table_extra_filters do %>
  <%# Checkbox %>
  <%= check_box_tag 'somekey', 'value', params['somekey'] %>

  <%# Select box %>
  <%= select_tag "credit_card", options_for_select({"VISA" => 'visa', "MasterCard" => 'master_card'}, params['credit_card']) %>

  <%# Text field %>
  <%= text_field_tag "somefield", params['somefield'] %>

  <%# Radio buttons %>
  <%= radio_button_tag("category", "", !params["category"].present?) %>
  <%= radio_button_tag("category", "rails", params["category"] == 'rails') %>
  <%= radio_button_tag("category", "java", params["category"] == 'java') %>
<% end %>
```

### Setting Up Defaults
```ruby
  smart_table_params = smart_table_params(
    initial_page_size: 20,
    initial_sort_attribute: :name,
    initial_sort_order: :desc
  )
```
