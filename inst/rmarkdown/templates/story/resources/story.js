$(document).ready(function () {
  $('.hamburger').click(function() {
    $(this).toggleClass('is-active')
    $('.full-menu').toggleClass('open')
    $('.topnav').toggleClass('open')
  })
  
  $('.topnav').affix({ offset: { top: 100 }})

  $('nav').parent().before($('nav'))
  
  /* Imágenes responsive*/
  $('img').addClass('img-responsive')
  
  /* Estructura HTML */
  var post = document.createElement('div');
  post.setAttribute('class', 'post');
  var postContent = document.createElement('div');
  postContent.setAttribute('class','post-content');
  $(post).prepend($(postContent))
  $('nav').after($(post))
  $(postContent).prepend($('.container'))
  $('.container').prepend('<div class="post-title">');
  $('.post-title').after('<div class="post-hero-image">');
  $('.post-hero-image').after('<div class="post-body">');

  /* Título del blog */
  $('.post-title').prepend($('h1')[0])
  /* Imagen principal del blog */
  $('.post-hero-image').prepend($(postContent).find('img')[0]);
  /* Contenido del blog */
  var siblings = $('.post-body').nextAll()
  siblings = siblings.filter(function (index, sibling) {
    return $(sibling).attr('id') !== 'footer'
  })
  $.map(siblings, function (sibling) {
    $('.post-body').append(sibling)
  })

})