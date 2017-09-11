$(document).ready(function () {

  $('.hamburger').click(function() {
    $(this).toggleClass('is-active')
    $('.full-menu').toggleClass('open')
    $('.topnav').toggleClass('open')
  })
  
  $('.topnav').affix({ offset: { top: 100 }})

  /* Contenedor para los posts */
  var main = document.createElement('main');
  $('header').after(main);
  
  var next = $(main).next();
  $(main).append(next)
  
  /* Obtiene los elementos con la clase 'level2' */
  var postsBox = $('.level2');
  
  /* Elimina el footer del arreglo si existe */
  postsBox = postsBox.filter(function (index, section) { 
    var section = $(section)
    return section.attr('id') !== 'footer'
  })
  
  /* Crea div con clase row */
  var postsContainer = document.createElement('div');
  postsContainer.setAttribute('class', 'row');
  
  /* Posiciona el div.row antes que cualquier elemento con clase 'level2' */
  postsBox[0].before(postsContainer);
  
  $.map(postsBox, function(postBox, index) {
    /* Posiciona los posts dentro de div.row */
    postsContainer.appendChild(postBox)
    /* Agrega clases BS para los posts */
    $(postBox).addClass('col-md-4').addClass('col-sm-6').addClass('col-xs-12').addClass('story')
    /* Elimina lo que no sea de nivel dos y div contenedor */
    $(postBox).find($('.level3')).remove()
    $(postBox).find($('.level4')).remove()
    $(postBox).find($('.level5')).remove()
    $(postBox).find($('.level6')).remove()
    /* Agrega contenedor secundario */
    $(postBox).prepend('<div class="story-box" id="story-box-' + index + '"></div>')
    /* Encuentra imágenes y las posiciona dentro de story-box*/
    $('#story-box-' + index)
      .prepend($(postBox).find('img'))
      .append('<div class="story-content" id="story-content-' + index + '"></div>')
    $('#story-content-' + index)
      .prepend($(postBox).find('h2'))
      .append($(postBox).find('p'))
  });
  
  /* Imágenes responsive */
  $('img').addClass('img-responsive')

  /* ScrollReveal */
  window.sr = ScrollReveal();
  sr.reveal('.story-box', { duration: 1800 }, 300);

  /* Crea el footer */
  var footer = document.createElement('footer');
  $('main').after(footer)
  console.log($(footer))
  $('footer').append('<div class="footer-container"></div>')
  $('.footer-container').append($('#footer'))
  $('#footer').find('h2').css("display", "none")
})