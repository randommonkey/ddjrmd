$(document).ready(function () {

  /* Responsive images */
  $('img').addClass('img-responsive');

  /* Center images */
  $('img').css({'margin-left': 'auto', 'margin-right': 'auto'});

  /* Main container */
  var main = document.createElement('main');
  $('header').after(main);

  /* Intro container */
  var intro = document.createElement('div');
  $(intro).addClass('intro').addClass('container');
  $(main).prepend(intro);

  /* Find first <p> tag and place it into intro container */
  var introText = $(main).nextAll('p')[0];
  $(intro).prepend(introText);

  /* Boxes container */
  var boxes = document.createElement('div');
  $(boxes).addClass('boxes');
  var container = document.createElement('div');
  $(container).addClass('container');
  var row = document.createElement('div');
  $(row).addClass('row');
  var half = $(container).prepend(row);
  var complete = $(boxes).prepend(half)
  $(intro).after(complete);
  
  /* Obtain .level2 elements */
  var boxes = $('.level1.level2');
  
  /* Delete footer if exists */
  boxes = boxes.filter(function (index, section) { 
    var section = $(section);
    return section.attr('id') !== 'footer';
  });

  $.map(boxes, function(box, index) {
    /* Place boxes into boxes container */
    $(row).prepend(box);
    /* Add some classes */
    $(box).addClass('story').addClass('col-md-4').addClass('col-sm-6').addClass('col-xs-12');
    /* Remove other titles sections */
    $(box).find($('.level3')).remove();
    $(box).find($('.level4')).remove();
    $(box).find($('.level5')).remove();
    $(box).find($('.level6')).remove();
    /* Find first link and reset */
    var link = $(box).find('a')[0];
    $(link).text('');
    /* Find first img */
    var img = $(box).find('img')[0];
    /* Place link at top */
    $(box).prepend(link);
    /* Container inside link */
    var storyBox = document.createElement('div');
    $(storyBox).addClass('story-box');
    $(link).prepend(storyBox);
    var storyImg = document.createElement('div');
    $(storyImg).addClass('story-img')
    /* Image inside container */
    $(storyBox).prepend(storyImg);
    $(storyImg).prepend(img);
    /* Get link siblings */
    var siblings = $(link).nextAll();
    /* box content */
    var storyContent = document.createElement('div');
    $(storyContent).addClass('story-content');
    $(storyBox).append(storyContent);
    /* Siblings in box content */
    $(storyContent).prepend(siblings);
    /* Hide description */
    $(box).find('p').css('display','none');
  })


  // Carrousel



  

  /* ScrollReveal */
  window.sr = ScrollReveal();
  sr.reveal('.story-box', { duration: 1800 }, 300);
})