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
  var seconds = parseInt(dom.innerHTML);
  var d = new Date();
  var epoch = (d.getTime() - d.getMilliseconds()) / 1000;

  dom.nextSibling.innerHTML = nice_time(epoch - seconds);
}

InlineForm = {
  toggleAdd: function(ele) {
    container = $(ele).up('.container');
    container.down('a.showlink').toggle();
    container.down('div.formWrapper').toggle();
  }
}

document.observe('contentloaded', function() {
  alert('table');
  //document.getElementsByTagName('table').each(zebra) //function(table){ zebra(table)  })
});