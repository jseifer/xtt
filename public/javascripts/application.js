var InlineForm = {
  toggleAdd: function(ele) {
    var container = $(ele).up('.container');
    container.down('a.showlink').toggle();
    container.down('div.form_wrapper').toggle();
  }
}

document.observe('dom:loaded', function() {
  
});
