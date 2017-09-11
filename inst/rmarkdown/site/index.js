$('.hamburger').click(function() {
  $(this).toggleClass('is-active')
  $('.full-menu').toggleClass('open')
  $('.topnav').toggleClass('open')
})

$('.topnav').affix({ offset: { top: 100 }})

  /* Style footer */
  // var footer = document.createElement('footer');
  // $('.post').after(footer)
  // $('footer').append('<div class="footer-container"></div>')
  $('.footer-container').append($('#footer'))
  $('#footer').find('h2').css("display", "none")


