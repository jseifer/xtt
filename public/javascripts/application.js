// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function zebra(host) {
  host = $(host);
  $A(host.getElementsByTagName('tr')).each(function(element,i){
    element.removeClassName('alternate')
    if (i % 2 == 1) element.addClassName('alternate')
  })
}

function nice_time(seconds) {
  var hours = (seconds / 3600).floor();
  seconds = seconds % 3600;
  var minutes = (seconds / 60).floor().toPaddedString(2);
  seconds = (seconds % 60).toPaddedString(2);
  return([hours, minutes, seconds].join(":"));
}

function timerIncrement(dom) {
  dom = $(dom);
  var seconds = 0;
  var value = dom.innerHTML.split(":").reverse();
  value.push(0); value.push(0);
  
  seconds = parseInt(value[0]) + 1;
  seconds += parseInt(value[1]) * 60;
  seconds += parseInt(value[2]) * 3600;

  dom.innerHTML = nice_time(seconds);
}