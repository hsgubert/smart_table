
// SmartTable class constructor (empty)
var SmartTable = function() {
}

// Helper function to setup onLoad
SmartTable.onPageLoad = function(callback){
    // modern browsers
    if (document.addEventListener) {
      if (typeof Turbolinks !== 'undefined') {
        document.addEventListener("turbolinks:load", callback); // Turbolinks 5
        document.addEventListener("page:load", callback); // Turbolinks classic
      } else {
        document.addEventListener('DOMContentLoaded', callback);
      }
    }
    // IE <= 8
    else {
      document.attachEvent('onreadystatechange', function() {
        if (document.readyState == 'complete') callback();
      });
    }
};

// make the initial setup of smart table links, filters, search, scoped under the
// selector parameter. If no selector parameter is passed, make the setup on the
// whole document
SmartTable.setupSmartTableInScope = function(selector) {
  var scopeElement;
  if (typeof selector == 'undefined') {
    scopeElement = document;
  } else {
    scopeElement = document.querySelector(selector);
  }
  if (scopeElement == null) {
    return;
  }

  // call individual setup methods
  SmartTable.setupSmartTableSearch(scopeElement);
  SmartTable.setupSmartTableExtraFilters(scopeElement);
  SmartTable.setupRemoteTableUpdate(scopeElement);
}

// On page load, we setup all JS elements on the whole document
SmartTable.onPageLoad(function(event) {
  SmartTable.setupSmartTableInScope();
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

  // if there is section to be updated dynamically, does AJAX request, otherwise
  // just makes the browser load the new page
  var url = SmartTable.currentUrlWithMergedQueryParams(params);
  if (!!document.querySelector('.smart_table_remote_updatable_content')) {
    SmartTable.ajaxUpdate(url, '.smart_table_remote_updatable_content');
  } else {
    window.location = url;
  }
}

// Updates table via ajax.
// 1) Does XHR HTTP GET to get new content
// 2) Uses replaceableElementSelector to select the element to be replaced in the current DOM,
//    by the element with the same selector in the received content
// 3) Replaces current browser url (necessary for smart_table to work properly)
// 4) Fires the "smart_table:ajax_update" event on the document, with the newly
// added element as target
SmartTable.ajaxUpdate = function(url, replaceableElementSelector) {
  // makes AJAX get request
  var xhr = new XMLHttpRequest();
  xhr.open('GET', url);
  xhr.onload = function() {
      if (xhr.status === 200) {
          // parses response
          var domParser = new DOMParser();
          var receivedDocument = domParser.parseFromString(xhr.responseText, "text/html");
          var replacingElement = receivedDocument.querySelector(replaceableElementSelector);
          if (replacingElement == null) {
            console.log("smart_table: element with selector '" + replaceableElementSelector + "' not found in xhr response");
            return;
          }

          // finds element to be replaced
          var replacedElement = document.querySelector(replaceableElementSelector);
          if (replacedElement == null) {
            console.log("smart_table: element with selector '" + replaceableElementSelector + "' not found in current document");
            return;
          }

          // replaces element
          replacedElement.parentNode.replaceChild(replacingElement, replacedElement);

          // re-do setup of smart_table, as it is probably inside the replaced element
          SmartTable.setupSmartTableInScope(replaceableElementSelector);

          // updates url (requires HTML5)
          history.replaceState({}, "", url)

          // fires "smart_table:ajax_update" event on document, in case there are
          // custom user actions to be done
          var ajaxUpdateEvent = new CustomEvent("smart_table:ajax_update", {
            detail: {
              replacedElementSelector: replaceableElementSelector
            }
          })
          document.dispatchEvent(ajaxUpdateEvent);
      }
      else {
          console.log("smart_table: xhr update failed. Response status: " + xhr.status);
      }
  };
  xhr.send();
}

// Prepares table search field, so the table is refreshed when the field changes
// scopeElement: scope under which all search fields will be setup. May be the document object
SmartTable.setupSmartTableSearch = function(scopeElement) {
  // gets search text field
  var smartTableSearch = scopeElement.getElementsByClassName('smart_table_search')[0];
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
// scopeElement: scope under which all search fields will be setup. May be the document object
SmartTable.setupSmartTableExtraFilters = function(scopeElement) {
  var smartTableExtraFilters = scopeElement.getElementsByClassName('smart_table_extra_filters')[0];
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

// Prepares all links with data-smart-table-remote-link to trigger ajax requests
// and replace part of the document only.
// scopeElement: scope under which all search fields will be setup. May be the document object
SmartTable.setupRemoteTableUpdate = function(scopeElement) {
  var remoteLinkNodes = scopeElement.querySelectorAll('a.smart-table-link[data-smart-table-remote-link]');
  if (remoteLinkNodes.length == 0) return;

  // refreshes page every time any field changes
  for (var i=0; i<remoteLinkNodes.length; i++) {
    var linkNode = remoteLinkNodes[i];
    linkNode.addEventListener('click', function(event) {
      event.preventDefault();
      SmartTable.ajaxUpdate(event.target.href, '.smart_table_remote_updatable_content');
      return false;
    });
  }
}
