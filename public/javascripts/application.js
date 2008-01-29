document.observe('dom:loaded', function() {
  // Make inputs with the class name hintable use their title attribute
  // for a hint.
  $$('input.hintable').invoke('hintable');
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