#' Home template
#'
#' Template for creating an R markdown document with minimal markup
#'
#' \if{html}{
#' \figure{minimal.png}{options: width="100\%" alt="Figure: minimal example"}
#' }
#'
#' \if{latex}{
#' \figure{minimal.pdf}{options: width=10cm}
#' }
#' @encoding UTF-8
#' @section  YAML Frontmatter:
#' The following example shows all possible YAML frontmatter options:
#' \preformatted{---
#' title: "INSERT_TITLE_HERE"
#' output: ddjrmd::minimal
#' ---}
#'
#' @inheritParams rmarkdown::html_document
#' @param extra_dependencies,... Additional function arguments to pass to the
#'        base R Markdown HTML output formatter
#' @examples \dontrun{
#' rmarkdown::render("source.Rmd", clean=TRUE, quiet=TRUE, output_file="output.html")
#' }
#' @export
story <- function(number_sections = FALSE,
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

  dep <- htmltools::htmlDependency("story", "0.1",
                                   src = system.file("rmarkdown", "templates", "story", "resources",
                                                     package = "ddjrmd"),
                                   stylesheet=c("story.css"),
                                   script = "story.js")

  extra_dependencies <- append(extra_dependencies, list(dep))

  args <- c("--standalone")
  args <- c(args, "--section-divs")
  args <- c(args, rmarkdown::pandoc_toc_args(toc, toc_depth))

  args <- c(args, "--template",
            rmarkdown::pandoc_path_arg(system.file("rmarkdown", "templates", "story", "base.html",
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


