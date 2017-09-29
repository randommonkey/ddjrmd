$(document).ready(function() {

    var disqus = $('#disqus_thread');

    // Handle seealso
    var seealso = {};
    seealso.data = $('#see-also>.section.level2').map(function() {
        var link = $(this).find('a')[0];
        link = $(link).attr("href")
        var title = $(this).find('h2')[0];
        title = $(title).text()
        var img = $(this).find('img')[0];
        img = $(img).attr("src")
        return ({ title: title, link: link, img: img })
    });
    // remove self
    seealso.data = $.makeArray(seealso.data);
    var url = window.location.href;
    url = url.replace(/^.*\/|\.*$/g, '')
    seealso.data = seealso.data.filter(function(el) {
        return el.link != url
    })
    console.log(url)
    console.log("seealso", seealso)
    if(seealso.data.length > 0){
      $('#seealsoContent').append(seealsoTemplate(seealso));    
    }
    // Remove all parsed sections
    $('#see-also').find('h1').remove();
    $('#see-also>.section.level2').remove();
    
    // Footer
    $('.footer-container').append($('#footer'))
    $('#footer').find('h1').remove()


    $('.owl-carousel').owlCarousel({
        center: true,
        items: 2,
        loop: true,
        margin: 5,
        nav: true,
        navText: ["<i class='fa fa-chevron-left'></i>", "<i class='fa fa-chevron-right'></i>"],
        responsive: {
            768: { items: 3 },
            992: { items: 3 },
            1200: { items: 4 },
            1920: { items: 8 }
        }
    });

    var footer = $('#footer').children().not('h1')
    $('.footer-container').append(footer)

    $('.see-also').before(disqus)
});