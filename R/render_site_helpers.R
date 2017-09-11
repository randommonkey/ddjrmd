

make_see_also <- function(config, f){
  see_also <- config$see_also
  see_also <- Filter(function(x){
    if(x == "index.Rmd") return(FALSE)
    tools::file_path_sans_ext(x$href) != tools::file_path_sans_ext(f)
    },see_also)
  see_also <- lapply(see_also,function(x){
    str_tpl_format('<div id="see_also">
                 <div class="cols-md-3"><a href="./{href}">{text}</a></div>
                 </div>
                 ',x)
  })
  see_also_html_str <- paste(unlist(see_also),collapse = "\n")
  as_tmpfile(see_also_html_str)
}


make_navbar <- function(input,files, config){
  #files <- input_files()
  navbar_template_file <- system.file("rmarkdown/site/_navbar.html", package = "ddjrmd")
  navbar_template <- paste(readLines(navbar_template_file),collapse = "\n")

  if(is.null(config$navbar)){
    textHref <- lapply(files,function(x){
      list(href = paste0(tools::file_path_sans_ext(x),".html"), text = yaml_front_matter(file.path(input,x))$title)
    })
  }else{
    textHref <- config$navbar$links
  }

  links <- lapply(textHref,function(x){
    str_tpl_format('<li><a href="./{href}">{text}</a></li>',x)
  })
  links <- paste(unlist(links),collapse = "\n")

  navbar_html_str <- str_tpl_format(navbar_template, list(logo = config$logo, links = links, title = config$name))
  as_tmpfile(navbar_html_str)
}
