$('.hamburger').click(function() {
  $(this).toggleClass('is-active')
  $('.full-menu').toggleClass('open')
  $('.topnav').toggleClass('open')
})

$('.topnav').affix({ offset: { top: 100 }})

window.sr = ScrollReveal();
sr.reveal('.story-box', { duration: 1800 }, 300);
