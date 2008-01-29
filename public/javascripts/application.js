document.observe('dom:loaded', function() {
  // Make inputs with the class name hintable use their title attribute
  // for a hint.
  $$('input.hintable').invoke('hintable');
  
  $('status_message').observe('keypress', function(event) {
    if(event.keyCode === Event.KEY_RETURN) {
      this.up('form').submit();
    }
  });
  
  
  // Grab all the day badges and if the user has their browser 
  // wide enough, show them on page load.  Also, when the user resizes 
  // their browser window run this check again.
  var dayBadges = $$('p.day-break');
  var showing = false;
  if(document.viewport.getWidth() > 1175) {
    dayBadges.invoke('show');
    showing = true;
  }
  Event.observe(window, 'resize', function() {
    var vpWidth = document.viewport.getWidth();
    if(vpWidth > 1175) {
      showing = true;
      dayBadges.invoke('show');
    } else if(vpWidth < 1175 && showing) {
      dayBadges.invoke('hide');
    } 
  });
});


(function() {
  // Get users Timezone offset, add it as a hidden field and 
  // submit it with every form
  var date = new Date();
  var offset = date.getTimezoneOffset();
  Cookie.set({tzoffset: offset});
})();



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