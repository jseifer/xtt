document.observe('dom:loaded', function() {

  $$('input.hint').each(function(i){
    Event.observe(i, 'focus', XTT.hintField);
    Event.observe(i, 'blur', XTT.unhintField);
  });
  XTT.adjust_utc();
});

XTT = {
  adjust_utc: function() {
    $$('input.utc_date').each(function(i){ 
      i.value = new Date(Date.parse(i.value)) 
    });
    $$('b.utc_date').each(function(i){
      i.innerHTML = new Date(Date.parse(i.innerHTML)) 
    });
  },
  
  /* justin: got a better way of doing this? :) c3 */
  hintField: function(event) {
    var element = Event.element(event);
    if (element.value == element.defaultValue) { 
      element.removeClassName('hint');
      element.value = '' 
    }
  },
  
  unhintField: function(event) {
    var element = Event.element(event);
    if (element.value == '') {
      element.value = element.defaultValue;
      element.addClassName('hint');
    }
  },
  nice_time: function(seconds) {
    /* live timer */
    var hours = (seconds / 3600).floor();
    seconds = seconds % 3600;
    var minutes = (seconds / 60).floor().toPaddedString(2);
    seconds = (seconds % 60).toPaddedString(2);
    return([hours, minutes, seconds].join(":"));
  },
  timerIncrement: function(dom) {
    dom = $(dom);
    var seconds = parseInt(dom.innerHTML);
    var d = new Date();
    var epoch = (d.getTime() - d.getMilliseconds()) / 1000;

    dom.nextSibling.innerHTML = XTT.nice_time(epoch - seconds);
  }
}