#' @export
ddj_site <- function(input, encoding = getOption("encoding"), ...) {

  # get the site config
  config <- site_config(input, encoding)
  if (is.null(config))
    stop("No site configuration (_site.yml) file found.")

  dots <- list(...)
  self_contained <- (dots$self_contained %||% config$self_contained) %||% FALSE

  # helper function to get all input files. includes all .Rmd and
  # .md files that don't start with "_" (note that we don't do this
  # recursively because rmarkdown in general handles applying common
  # options/elements across subdirectories poorly)
  input_files <- function() {
    list.files(input, pattern = "^[^_].*\\.[Rr]?md$")
  }

  # define render function (use ... to gracefully handle future args)
  render <- function(input_file,
                     output_format,
                     envir,
                     quiet,
                     encoding, ...) {

    # track outputs
    outputs <- c()

    # see if this is an incremental render
    incremental <- !is.null(input_file)

    # files list is either a single file (for incremental) or all
    # file within the input directory
    if (incremental)
      files <- input_file
    else {
      files <- file.path(input, input_files())
    }

    dep_site <- htmltools::htmlDependency("site", "0.1",
                                          src = system.file("rmarkdown", "site",
                                                            package = "ddjrmd"),
                                          stylesheet=c("hamburgers.min.css", "site.css"),
                                          script = c("site.js","handlebars.min.js"),
                                          all_files = FALSE)
    extra_dependencies <- list(dep_site)



    # Add args
    args <- pandoc_metadata_arg("logo",config$logo)
    #args <- c(args, pandoc_metadata_arg("debug",TRUE))

    # Add custom site css
    if(!is.null(config$css))
      args <- c(args, "--css", rmarkdown::pandoc_path_arg(config$css))

    # Header includes
    header_includes <- NULL
    if(!is.null(config$header)){
      htmlfiles <- file.path(input,config$header)
      htmlfiles <- paste(unlist(lapply(htmlfiles, readLines)), collapse = "\n")
      header_includes <-as_tmpfile(htmlfiles)
    }

    # Body includes
    body_includes <- NULL
    if(!is.null(config$body)){
      htmlfiles <- file.path(input,config$body)
      htmlfiles <- paste(unlist(lapply(htmlfiles, readLines)), collapse = "\n")
      body_includes <-as_tmpfile(htmlfiles)
    }

    # Make navbar
    navbar_tempfile <- make_navbar(input, input_files(),config)

    # Make see also
    ## make it for each Rmd from site config, removing current post
    see_also_handlebars <- system.file("rmarkdown/site/_hb_seealso.html", package = "ddjrmd")
    see_also_handlebars <- paste(readLines(see_also_handlebars),collapse = "\n")
    see_also_html_str <- paste(see_also_handlebars,collapse = "\n")
    see_also_tempfile <- as_tmpfile(see_also_html_str)

    # Make footer
    footer_file <- system.file("rmarkdown/site/_footer.html", package = "ddjrmd")
    footer_lines <- paste(readLines(footer_file),collapse = "\n")
    footer_tempfile <- as_tmpfile(footer_lines)

    ## Render files

    sapply(files, function(x) {
      message("FILES")
      args <- c(args, pandoc_metadata_arg("currentFile",tools::file_path_sans_ext(x)))
      # we suppress messages so that "Output created" isn't emitted
      # (which could result in RStudio previewing the wrong file)



      output <- suppressMessages(
        rmarkdown::render(x,
                          output_format = output_format,
                          #params = params,
                          output_options = list(lib_dir = "assets",
                                                self_contained = self_contained,
                                                #pandoc_args = c("--metadata","debug=TRUE"),
                                                pandoc_args = args,
                                                includes = list(
                                                  in_header = header_includes,
                                                  before_body = navbar_tempfile,
                                                  after_body = c(
                                                    body_includes,
                                                    see_also_tempfile,
                                                    footer_tempfile)),
                                                extra_dependencies = extra_dependencies
                          ),
                          envir = envir,
                          quiet = quiet,
                          encoding = encoding)
      )

      # add to global list of outputs
      outputs <<- c(outputs, output)

      # check for files dir and add that as well
      sidecar_files_dir <- knitr_files_dir(output)
      files_dir_info <- file.info(sidecar_files_dir)
      if (isTRUE(files_dir_info$isdir))
        outputs <<- c(outputs, sidecar_files_dir)
    })

    # do we have a relative output directory? if so then remove,
    # recreate, and copy outputs to it (we don't however remove
    # it for incremental builds)
    if (config$output_dir != '.') {

      # remove and recreate output dir if necessary
      output_dir <- file.path(input, config$output_dir)
      if (file.exists(output_dir)) {
        if (!incremental) {
          unlink(output_dir, recursive = TRUE)
          dir.create(output_dir)
        }
      } else {
        dir.create(output_dir)
      }

      # move outputs
      for (output in outputs) {

        # don't move it if it's a _files dir that has a _cache dir
        if (grepl("^.*_files$", output)) {
          cache_dir <- gsub("_files$", "_cache", output)
          if (dir_exists(cache_dir))
            next;
        }

        output_dest <- file.path(output_dir, basename(output))
        if (dir_exists(output_dest))
          unlink(output_dest, recursive = TRUE)
        file.rename(output, output_dest)
      }

      # copy lib dir a directory at a time (allows it to work with incremental)
      lib_dir <- file.path(input, "site_libs")
      output_lib_dir <- file.path(output_dir, "site_libs")
      if (!file.exists(output_lib_dir))
        dir.create(output_lib_dir)
      libs <- list.files(lib_dir)
      for (lib in libs)
        file.copy(file.path(lib_dir, lib), output_lib_dir, recursive = TRUE)
      unlink(lib_dir, recursive = TRUE)

      # copy other files
      copy_site_resources(input, encoding)
    }

    # Print output created for rstudio preview
    if (!quiet) {
      # determine output file
      output_file <- ifelse(is.null(input_file),
                            "index.html",
                            file_with_ext(basename(input_file), "html"))
      if (config$output_dir != ".")
        output_file <- file.path(config$output_dir, output_file)
      message("\nOutput created: ", output_file)
    }
  }

  # define clean function
  clean <- function() {

    # build list of generated files
    generated <- c()

    # enumerate rendered markdown files
    files <- input_files()

    # get html files
    html_files <- file_with_ext(files, "html")

    # _files peers are always removed (they could be here due to
    # output_dir == "." or due to a _cache existing for the page)
    html_supporting <- paste0(knitr_files_dir(html_files), '/')
    generated <- c(generated, html_supporting)

    # _cache peers are always removed
    html_cache <- paste0(knitr_root_cache_dir(html_files), '/')
    generated <- c(generated, html_cache)

    # for rendering in the current directory we need to eliminate
    # output files for our inputs (including _files) and the lib dir
    if (config$output_dir == ".") {

      # .html peers
      generated <- c(generated, html_files)

      # site_libs dir
      generated <- c(generated, "site_libs/")

      # for an explicit output_dir just remove the directory
    } else {
      generated <- c(generated, paste0(config$output_dir, '/'))
    }

    # filter out by existence
    generated[file.exists(file.path(input, generated))]
  }

  # return site generator
  list(
    name = config$name,
    output_dir = config$output_dir,
    render = render,
    clean = clean
  )
}




pandoc_metadata_arg <- function(name, value) {
  c("--metadata", if (missing(value)) name else paste(name, "=", value, sep = ""))
}

# helper function to get the site configuration as an R list
site_config <- function(input, encoding = getOption("encoding")) {

  # normalize input
  input <- input_as_dir(input)

  # check for config file
  config_file <- site_config_file(input)
  if (file.exists(config_file)) {

    # parse the yaml
    config_lines <- read_lines_utf8(config_file, encoding)
    config <- yaml_load_utf8(config_lines)
    if (!is.list(config))
      config <- list()

    # provide defaults if necessary
    if (is.null(config$name))
      config$name <- basename(normalize_path(input))
    if (is.null(config$output_dir))
      config$output_dir <- "_site"
    if(is.null(config$logo)){
      default_logo <- system.file("resources","public","assets","images","ds.png", package = "ddjrmd")
      file.copy(default_logo, input)
      config$logo <- "ds.png"
    }

    # return config
    config

    # no _site.yml
  } else {
    NULL
  }
}


# get the path to the site config file
site_config_file <- function(input) {
  file.path(input, "_site.yml")
}






