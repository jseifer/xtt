document.observe('dom:loaded', function() {

  $$('input.hint').each(function(i){
    Event.observe(i, 'focus', hintField);
    Event.observe(i, 'blur', unhintField);
  });
  $$('.utc_date').each(function(i){
    $(i).innerHTML = new Date(Date.parse(i.innerHTML));
  })

});

/* justin: got a better way of doing this? :) c3 */
function hintField(event) {
  var element = Event.element(event);
  if (element.value == element.defaultValue) { 
    element.removeClassName('hint');
    element.value = '' 
  } 
}

function unhintField(event) {
  var element = Event.element(event);
  if (element.value == '') {
    element.value = element.defaultValue;
    element.addClassName('hint');
  }
}

/* live timer */
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
