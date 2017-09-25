$(document).ready(function() {

    /* Imágenes responsive*/
    $('main img').addClass('img-responsive')
    /* Center images */
    $('main img').css({ 'margin-left': 'auto', 'margin-right': 'auto' })
    $('.section.level2').children().not(".fullwidth").addClass('post-margin');
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
    seealso.data = seealso.data.filter(function(el){
      return el.link != url
    })
    console.log(url)
    console.log("seealso",seealso)
    $('#seealsoContent').append(seealsoTemplate(seealso));
    // Remove all parsed sections
    $('#see-also').find('h1').remove();
    $('#see-also>.section.level2').remove();
    // Footer
    $('.footer-container').append($('#footer'))
    $('#footer').find('h1').remove()

})