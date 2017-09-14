$('.hamburger').click(function() {
  $(this).toggleClass('is-active')
  $('.full-menu').toggleClass('open')
  $('.topnav').toggleClass('open')
})

$('.topnav').affix({ offset: { top: 100 }})

// $(window).load(function () {
$(document).ready(function () {
	console.log("moving footer")
	/* Add footer */
	$('.footer-container').append($('#footer'))
	$('#footer').find('h2').remove()
// $('footer').appendTo('body')
// $('.post').after(footer)

})