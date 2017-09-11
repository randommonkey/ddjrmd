#' Static template
#' @export
static <- function(number_sections = FALSE,
                  fig_width = 7,
                  fig_height = 5,
                  fig_retina = if (!fig_caption) 2,
                  fig_caption = FALSE,
                  dev = 'png',
                  toc = FALSE,
                  toc_depth = 3,
                  smart = TRUE,
                  self_contained = TRUE,
                  highlight = NULL,
                  mathjax = "default",
                  extra_dependencies = NULL,
                  css = NULL,
                  includes = NULL,
                  keep_md = FALSE,
                  lib_dir = NULL,
                  md_extensions = NULL,
                  pandoc_args = NULL,
                  ...) {

  theme <- NULL
  template <- "default"
  code_folding <- "none"

  dep_site <- htmltools::htmlDependency("site", "0.1",
                                        src = system.file("rmarkdown", "site",
                                                          package = "ddjrmd"),
                                        stylesheet=c("hamburgers.min.css", "index.css"),
                                        script = "index.js",
                                        all_files = FALSE
  )

  dep <- htmltools::htmlDependency("static", "0.1",
                                   src = system.file("rmarkdown", "templates", "static", "resources",
                                                     package = "ddjrmd"),
                                   stylesheet=c("static.css"),
                                   script = "static.js")

  extra_dependencies <- append(extra_dependencies, list(dep_site, dep))

  args <- c("--standalone")
  args <- c(args, "--section-divs")
  args <- c(args, rmarkdown::pandoc_toc_args(toc, toc_depth))

  args <- c(args, "--template",
            rmarkdown::pandoc_path_arg(system.file("rmarkdown", "templates", "static", "base.html",
                                                   package = "ddjrmd")))

  if (number_sections)
    args <- c(args, "--number-sections")

  for (css_file in css)
    args <- c(args, "--css", rmarkdown::pandoc_path_arg(css_file))

  pre_processor <- function(metadata, input_file, runtime,
                            knit_meta, files_dir, output_dir) {

    if (is.null(lib_dir)) lib_dir <- files_dir

    args <- c()
    args <- c(args, pandoc_html_highlight_args(highlight,
                                               template, self_contained, lib_dir,
                                               output_dir))
    args <- c(args, includes_to_pandoc_args(includes = includes,
                                            filter = if (identical(runtime, "shiny"))
                                              normalize_path else identity))
    args

  }


  # determine knitr options
  knitr_options <- knitr_options_html(fig_width = fig_width,
                                      fig_height = fig_height,
                                      fig_retina = fig_retina,
                                      keep_md = FALSE,
                                      dev = dev)
  knitr_options$opts_chunk$echo = FALSE
  knitr_options$opts_chunk$warning = FALSE
  knitr_options$opts_chunk$message = FALSE
  knitr_options$opts_chunk$comment = NA

  # https://github.com/rstudio/flexdashboard/blob/master/R/flex_dashboard.R

  output_format(
    knitr = knitr_options,
    pandoc = rmarkdown::pandoc_options(to = "html",
                                       from = from_rmarkdown(fig_caption,
                                                             md_extensions),
                                       args = args),
    keep_md = keep_md,
    clean_supporting = self_contained,
    #pre_knit = pre_knit,
    pre_processor = pre_processor,
    #on_exit = on_exit,
    base_format = rmarkdown::html_document_base(smart = smart,
                                                theme = theme,
                                                self_contained = self_contained,
                                                lib_dir = lib_dir,
                                                highlight = highlight,
                                                mathjax = mathjax,
                                                template = template,
                                                pandoc_args = pandoc_args,
                                                extra_dependencies = extra_dependencies,
                                                ...))
}

