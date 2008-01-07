// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function zebra(host) {
  host = $(host);
  $A(host.getElementsByTagName('tr')).each(function(element,i){
    element.removeClassName('alternate')
    if (i % 2 == 1) element.addClassName('alternate')
  })
}
