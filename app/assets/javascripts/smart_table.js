
// SmartTable class constructor (empty)
var SmartTable = function() {
}

// Helper function to setup onLoad
SmartTable.onPageLoad = function(callback){
    // modern browsers
    if (document.addEventListener) {
      document.addEventListener('DOMContentLoaded', callback);
      document.addEventListener("turbolinks:load", callback); // Turbolinks 5
      document.addEventListener("page:load", callback); // Turbolinks classic
    }
    // IE <= 8
    else {
      document.attachEvent('onreadystatechange', function() {
        if (document.readyState == 'complete') callback();
      });
    }
};

// On page load, we setup search field and extra filters
SmartTable.onPageLoad(function() {
  SmartTable.setupSmartTableSearch();
  SmartTable.setupSmartTableExtraFilters();
})

// Gets the current page url and merges some query parameters to this url. If a
// certain parameter already exists, it is overwritten. If the value of the
// parameter in the argument map is "null", the parameter is removed from the url.
//   params: object containing parameters to be included in the url.
SmartTable.currentUrlWithMergedQueryParams = function(params) {
  // parses url and its query params
  var location = window.location;
  var vars = location.search.substring(1).split('&');
  var queryParams = {};
  if (!!vars && vars.length >0 && vars[0] != "") {
    for (var i=0; i<vars.length; i++) {
        var pair = vars[i].split('=');

        // decodeURIComponent does not decode '+' into space, so we do some preprocessing
        // and replace '+' for '%20', which is decoded to space by decodeURIComponent
        pair[1] = pair[1].replace(/\+/g, '%20');

        queryParams[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1]);
    }
  }

  // merges received params
  for (var key in params) {
    if (params[key] != null) {
      queryParams[key] = params[key];
    } else {
      delete queryParams[key];
    }
  }

  // rebuilds url
  var newSearchString = null;
  for (var key in queryParams) {
    if (newSearchString == null) {
      newSearchString = "?";
    } else {
      newSearchString += "&";
    }
    newSearchString += encodeURIComponent(key) + "=" + encodeURIComponent(queryParams[key]);
  }

  // returns new url
  return location.origin + location.pathname + newSearchString;
}

// Refreshes the current page, adding a pair of key value to the url's query string.
// If value is "null", the parameter is removed from the url.
// It also adds an extra parameter "st_page" so the table goes back to first
// page
SmartTable.refreshPageWithParam = function(key, value) {
  var params = {
    st_page: 1,
  }
  if (!!value && value.length > 0) {
    params[key] = value;
  } else {
    params[key] = null;
  }

  // makes the request
  window.location = SmartTable.currentUrlWithMergedQueryParams(params);
}

// Prepares table search field, so the table is refreshed when the field changes
SmartTable.setupSmartTableSearch = function() {
  // gets search text field
  var smartTableSearch = document.getElementById('smart_table_search');
  if (!smartTableSearch) return;

  // refreshes page every time search field changes
  smartTableSearch.addEventListener('change', function(event) {
    // get search string from field value
    var searchString = event.currentTarget.value;
    SmartTable.refreshPageWithParam("st_search", searchString);
  });
}

// Prepares table extra filters section, so the table is refreshed when the
// any of the input fields are changed
SmartTable.setupSmartTableExtraFilters = function() {
  var smartTableExtraFilters = document.getElementById('smart_table_extra_filters');
  if (!smartTableExtraFilters) return;

  // all input fields
  var inputNodes = smartTableExtraFilters.getElementsByTagName('input');
  var selectNodes = smartTableExtraFilters.getElementsByTagName('select');
  var nodeCollections = [inputNodes, selectNodes];

  // refreshes page every time any field changes
  for (var i=0; i<nodeCollections.length; i++) {
    var nodeCollection = nodeCollections[i];
    for (var j=0; j<nodeCollection.length; j++) {
      var node = nodeCollection[j];
      node.addEventListener('change', function(event) {
        if (event.target.type == 'checkbox' || event.target.type == 'radio') {
          var checkboxOrRadio = event.target;
          SmartTable.refreshPageWithParam(checkboxOrRadio.name, (checkboxOrRadio.checked ? checkboxOrRadio.value : ""));
        }
        else if (event.target.type == 'text') {
          var textField = event.target;
          SmartTable.refreshPageWithParam(textField.name, textField.value);
        }
        else if (event.target.type == 'select-one') {
          var select = event.target;
          SmartTable.refreshPageWithParam(select.name, select.value);
        }
      });
    }
  }
}
