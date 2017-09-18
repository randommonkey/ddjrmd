$(document).ready(function () {
  $('.hamburger').click(function() {
    $(this).toggleClass('is-active')
    $('.full-menu').toggleClass('open')
    $('.topnav').toggleClass('open')
  })
  
  $('.topnav').affix({ offset: { top: 100 }})

  $('body').prepend($('nav'))
  
  /* Imágenes responsive*/
  $('img').addClass('img-responsive')
  
  /* Estructura HTML */
  var post = document.createElement('div');
  $(post).addClass('post');
  var postContent = document.createElement('div');
  $(postContent).addClass('post-content');
  $(post).prepend($(postContent))
  var postTitle = document.createElement('div');
  $(postTitle).addClass('post-title');
  $(postContent).prepend(postTitle)
  $('nav').after($(post))
  $('.post-title').after('<div class="post-hero-image">');

  /* Título del blog */
  $('.post-title').prepend($('h1')[0]);
  /* Imagen principal del blog */
  var heroImage = $(post).nextAll().find('img')[0];
  $('.post-hero-image').prepend(heroImage);
  /* Contenido del blog */
  var siblings = $('.post').nextAll();
  siblings = siblings.filter(function (index, sibling) {
    var isFooter = $(sibling).is('footer');
    var isScript = $(sibling).is('script');
    var eval = isFooter ? false : (isScript ? false : true);
    return $(sibling).attr('class') == 'see_also' ? false : (eval ? true : false)
  })
  console.log(siblings)
  $.map(siblings, function (sibling) {
    $('.post-content').append(sibling)
  })
  /* Find post images */
  var images = $('.post-hero-image').nextAll().find('img');
  /* Add class to everything but images */
  $('.post-hero-image').nextAll().not(images).not('div').addClass('post-margin');
  /* Find img within a p */
  var paragraphsImages = $('.post').find('p:has(img)');
  $('.post-hero-image').nextAll().children().not('.fullwidth').addClass('post-margin');
  paragraphsImages.removeClass('post-margin')
  /* Center images */
  paragraphsImages.children().css({ 'margin-left': 'auto', 'margin-right': 'auto'})
  /* See also section */
  var seeAlso = $('.see_also');
  var container = document.createElement('div');
  $(container).addClass('container related');
  var row = document.createElement('div');
  $(row).addClass('row');
  $(seeAlso)[0].before(container);
  $('.related').append(row)
  $.map(seeAlso, function (box, index) {
    $(box).addClass('col-md-3').addClass('col-xs-6').addClass('col-sm-4');
    $(box).prepend('<div class="related_img" id="related_img_' + index + '">');
    $('.related .row').append(box);
    var relatedImg = $(box).find('img');
    var relatedLink = $(box).find('a');
    $('#related_img_' + index).prepend(relatedImg);
    $('#related_img_' + index).append(relatedLink);
  })
})