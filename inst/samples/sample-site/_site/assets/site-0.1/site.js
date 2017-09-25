$(document).ready(function() {
  $('.hamburger').click(function() {
    $(this).toggleClass('is-active')
    $('.full-menu').toggleClass('open')
    $('.topnav').toggleClass('open')
  });
  $('.topnav').affix({ offset: { top: 100 } });
  /* Add see also */
  // $('.seealsoContainer').append($('#see-also'))
  // $('#see-also').find('h1').remove()
  /* Add footer */
  $('.footer-container').append($('#footer'))
  $('#footer').find('h1').remove()

})