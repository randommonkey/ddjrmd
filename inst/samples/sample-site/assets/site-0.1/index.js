$('.hamburger').click(function() {
  $(this).toggleClass('is-active')
  $('.full-menu').toggleClass('open')
  $('.topnav').toggleClass('open')
})

$('.topnav').affix({ offset: { top: 100 }})
