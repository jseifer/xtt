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

  $$('span.time').each(function(span) {
		if(span.hasClassName("formatted"))
			span.update(Date.parseUTC(span.innerHTML).strftime("%I:%m %p"));
		else
    	span.update(Date.parseUTC(span.innerHTML).timeAgoInWords());
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

// http://redhanded.hobix.com/inspect/showingPerfectTime.html
/* other support functions -- thanks, ecmanaut! */
var strftime_funks = {
  zeropad: function( n ){ return n > 9 ? n : '0' + n; },
  a: function(t) { return ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][t.getDay()] },
  A: function(t) { return ['Sunday','Monday','Tuedsay','Wednesday','Thursday','Friday','Saturday'][t.getDay()] },
  b: function(t) { return ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'][t.getMonth()] },
  B: function(t) { return ['January','February','March','April','May','June', 'July','August',
      'September','October','November','December'][t.getMonth()] },
  c: function(t) { return t.toString() },
  d: function(t) { return this.zeropad(t.getDate()) },
  H: function(t) { return this.zeropad(t.getHours()) },
  I: function(t) { return this.zeropad((t.getHours() + 12) % 12) },
  m: function(t) { return this.zeropad(t.getMonth()+1) }, // month-1
  M: function(t) { return this.zeropad(t.getMinutes()) },
  p: function(t) { return this.H(t) < 12 ? 'AM' : 'PM'; },
  S: function(t) { return this.zeropad(t.getSeconds()) },
  w: function(t) { return t.getDay() }, // 0..6 == sun..sat
  y: function(t) { return this.zeropad(this.Y(t) % 100); },
  Y: function(t) { return t.getFullYear() },
  '%': function(t) { return '%' }
};

Date.prototype.strftime = function (fmt) {
    var t = this;
    for (var s in strftime_funks) {
        if (s.length == 1 )
            fmt = fmt.replace('%' + s, strftime_funks[s](t));
    }
    return fmt;
};

// http://twitter.pbwiki.com/RelativeTimeScripts
Date.distanceOfTimeInWords = function(fromTime, toTime, includeTime) {
  var delta = parseInt((toTime.getTime() - fromTime.getTime()) / 1000);
  if(delta < 60) {
      return 'less than a minute ago';
  } else if(delta < 120) {
      return 'about a minute ago';
  } else if(delta < (45*60)) {
      return (parseInt(delta / 60)).toString() + ' minutes ago';
  } else if(delta < (120*60)) {
      return 'about an hour ago';
  } else if(delta < (24*60*60)) {
      return 'about ' + (parseInt(delta / 3600)).toString() + ' hours ago';
  } else if(delta < (48*60*60)) {
      return '1 day ago';
  } else {
    var days = (parseInt(delta / 86400)).toString();
    if(days > 5) {
      var fmt  = '%B %d'
      if(toTime.getYear() != fromTime.getYear()) { fmt += ', %Y' }
      if(includeTime) fmt += ' %I:%M %p'
      return fromTime.strftime(fmt);
    } else {
      return days + " days ago"
    }
  }
}

Date.prototype.timeAgoInWords = function() {
  var relative_to = (arguments.length > 0) ? arguments[1] : new Date();
  return Date.distanceOfTimeInWords(this, relative_to, arguments[2]);
}

// for those times when you get a UTC string like 18 May 09:22 AM
Date.parseUTC = function(value) {
  var localDate = new Date(value);
  var utcSeconds = Date.UTC(localDate.getFullYear(), localDate.getMonth(), localDate.getDate(), localDate.getHours(), localDate.getMinutes(), localDate.getSeconds())
  return new Date(utcSeconds);
}