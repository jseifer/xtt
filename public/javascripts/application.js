document.observe('dom:loaded', function() {
  // Make inputs with the class name hintable use their title attribute
  // for a hint.
  $$('input.hintable').invoke('hintable');
  
  // Get users Timezone offset, add it as a hidden field and 
  // submit it with every form
  var date = new Date();
  var offset = date.getTimezoneOffset();
  $$('form').each(function(form) {
    var input = new Element('input', {type:'hidden', name:'tzoffset', class:'tzoffset'});
    form.insert(input);
  });
  $$('input.tzoffset').invoke('setValue', offset);
  
});

// var XTT = {
//   adjust_utc: function() {
//     $$('input.utc').each(function(input){ 
//       input.setValue(new DateTime($F(input)).toLocalString());
//     });
//     $$('span.utc').each(function(i){
//       i.innerHTML = new Date(Date.parse(i.innerHTML)) 
//     });
//   },
// 
//   nice_time: function(seconds) {
//     /* live timer */
//     var hours = (seconds / 3600).floor();
//     seconds = seconds % 3600;
//     var minutes = (seconds / 60).floor().toPaddedString(2);
//     seconds = (seconds % 60).toPaddedString(2);
//     return([hours, minutes, seconds].join(":"));
//   },
//   
//   timerIncrement: function(dom) {
//     dom = $(dom);
//     var seconds = parseInt(dom.innerHTML);
//     var d = new Date();
//     var epoch = (d.getTime() - d.getMilliseconds()) / 1000;
// 
//     dom.nextSibling.innerHTML = XTT.nice_time(epoch - seconds);
//   }
// }

// var DateTime = Class.create({
//   initialize: function(date) {
//     this.dateTime = "";
//     if(Object.isString(date))
//       this.dateTime = new Date(Date.parse(date));
//     else if(date.constructor == Date) {
//       this.dateTime = date;
//     }
//   },
//   
//   toLocalString: function() {
//     return this.dateTime.toLocaleString();
//   }
// })

Element.addMethods('INPUT', {
  /**
   * Add hints to input elements.
   * Add the class name hintable to all elements that you want to hint.
   * Use the title attribute of the input to provide the hint.
   */
  hintable: function(element) {
    var element = $(element), title = element.readAttribute('title');
    element.setValue(title);
    element.observe('focus', function() {
      element.removeClassName('hintable');
      if($F(element) != title) return;
      element.setValue('');
    });
    element.observe('blur', function() {
      if($F(element) == "") {
        element.addClassName('hintable');
        element.setValue(title);
      }
    });
  }
});