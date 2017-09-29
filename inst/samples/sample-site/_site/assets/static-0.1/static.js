$(document).ready(function() {
    var footer = $('#footer').children().not('h1')
    $('.footer-container').append(footer)

        $('.owl-carousel').owlCarousel({
        center: true,
        items: 2,
        loop: true,
        margin: 5,
        nav: true,
        navText: ["<i class='fa fa-chevron-left'></i>","<i class='fa fa-chevron-right'></i>"],
        responsive: {
            768: { items: 3 },
            992: { items: 3 },
            1200: { items: 4 },
            1920: { items: 8 }
        }
    });
});