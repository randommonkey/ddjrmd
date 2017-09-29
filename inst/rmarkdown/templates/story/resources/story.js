$(document).ready(function() {
    var disqus = $('#disqus_thread');

    /* Imágenes responsive*/
    $('main img').addClass('img-responsive')
    /* Center images */
    $('main img').css({ 'margin-left': 'auto', 'margin-right': 'auto' })
    $('.section.level2').children().not(".fullwidth").not(".level3").addClass('post-margin');
    $('.section.level3').children().not(".fullwidth").not(".level4").addClass('post-margin');
    $('.section.level4').children().not(".fullwidth").addClass('post-margin');
    $('main > p').not(".post-fullwidth").addClass('post-margin');
    $('main > blockquote').not(".post-fullwidth").addClass('post-margin');

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


    // Handle layout-twocolumn

    $(".section.level1.layout-twocolumn").map(function(){
        var twocolSection = $(this)
        var twocolSectionContent = $(twocolSection).find(".section.level2");
        $(twocolSection).find(".section.level2").find("h2").remove();
        var $div = $("<div>", {"class": "apps-box" });
        $(twocolSection).addClass("app-box");
        twocolSectionContent.addClass("app");
        $div.append(twocolSectionContent);
        // $('.section.level1').remove();
        console.log($div)
        $(twocolSection).append($div);
    });

    $('main').find('h1').not(".post-title").remove()

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
    $('.see-also').before(disqus)


})