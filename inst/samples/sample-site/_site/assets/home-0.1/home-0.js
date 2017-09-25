/* ScrollReveal */
window.sr = ScrollReveal();
sr.reveal('.story-box', { duration: 1800 }, 300);

$(document).ready(function() {

    $('.hamburger').click(function() {
        $(this).toggleClass('is-active')
        $('.full-menu').toggleClass('open')
        $('.topnav').toggleClass('open')
    });

    $('.topnav').affix({ offset: { top: 100 } });

    /* Responsive images */
    $('img').addClass('img-responsive');

    /* Center images */
    $('img').css({ 'margin-left': 'auto', 'margin-right': 'auto' });

    // /* Main container */
    // var main = document.createElement('main');
    // $('header').after(main);
    var main = $('main');

    /* Intro container */
    var introText = $("main").find("p:first");
    // $("main").find("p:first").remove();
    console.log("Intro text",introText)
    $("#intro").append(introText);

    // Handle sections
    var sections = $('.section.level1').map(function() {
        var section = {}
        section.id = $(this).attr('id');
        section.type = $(this).attr('class').replace("section level1 ", "");
        // var $div = $("<div>", { id: "new-" + section.id, "class": section.type });
        // $("body").append($div);
        // console.log($(this))
        if (section.type == "boxes") {
            // console.log("#" + section.id + '>.section.level2')
            var boxes = $("#" + section.id + '>.section.level2');
            /* Delete footer if exists */
            boxes = boxes.filter(function(index, section) {
                var section = $(section);
                return section.attr('id') !== 'footer';
            });
            section.data = boxes.map(function(index, box) {
                var link = $(box).find('a')[0];
                link = $(link).attr("href")
                var title = $(box).find('h2')[0];
                title = $(title).text()
                var img = $(box).find('img')[0];
                img = $(img).attr("src")
                // var paragraph = $(box).find('p');
                // paragraph = $(paragraph).outerHTML();
                var paragraph = "paragraph";
                return ({ title: title, link: link, img: img, paragraph: paragraph })
            })
            /* Place link at top */
            // console.log("BOXES", section.data)
        }
        if (section.type == "carrousel") {
            var slides = $("#" + section.id + '>.section.level2');
            slides = slides.filter(function(index, section) {
                var section = $(section);
                return section.attr('id') !== 'footer';
            });
            section.data = slides.map(function(index, slide) {
                var link = $(slide).find('a')[0];
                link = $(link).attr("href")
                var title = $(slide).find('h2')[0];
                title = $(title).text()
                var img = $(slide).find('img')[0];
                img = $(img).attr("src")
                // var paragraph = $(slide).find('p');
                // paragraph = $(paragraph).outerHTML();
                var paragraph = "paragraph";
                return ({ title: title, link: link, img: img, paragraph: paragraph })
            })
        }
        if (section.type == "layout-twocolumn"){
            var twocolSection = $(".section.level1.layout-twocolumn");
            var twocolSectionContent = $(twocolSection).find(".section.level2");
            $(twocolSection).find(".section.level2").find("h2").remove();
            var $div = $("<div>", {"class": "apps-box" });
            $(twocolSection).addClass("app-box");
            // $("#parsedContent").append($div);
            twocolSectionContent.addClass("app");
            $div.append(twocolSectionContent);
                $('.section.level1').remove();

            section.data = $div;
        }
        return section
    });
    // Remove all parsed sections
    $('.section.level1').remove();

    console.log("SECTIONS", sections)

    // Render templates
    sections.map(function(index, s) {

        if (s.type == "boxes") {
            s.data = $.makeArray(s.data);
            $('#parsedContent').append(boxesTemplate(s));
        }
        if (s.type == "carrousel") {
            s.data = $.makeArray(s.data);
            $('#parsedContent').append(carrouselTemplate(s));
        }
        if (s.type == "layout-twocolumn") {
            console.log("Two col div",s.data)
            $('#parsedContent').append(s.data);
        }
    })



    // Handle layout-twocolumn



})