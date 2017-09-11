
#' Parse the YAML front matter from a file
#'
#' @inheritParams default_output_format
#'
#' @keywords internal
#' @export
yaml_front_matter <- function(input, encoding = getOption("encoding")) {

  # read the input file
  input_lines <- read_lines_utf8(input, encoding)

  # parse the yaml front matter
  parse_yaml_front_matter(input_lines)
}

parse_yaml_front_matter <- function(input_lines) {

  partitions <- partition_yaml_front_matter(input_lines)
  if (!is.null(partitions$front_matter)) {
    front_matter <- partitions$front_matter
    if (length(front_matter) > 2) {
      front_matter <- front_matter[2:(length(front_matter)-1)]
      front_matter <- paste(front_matter, collapse="\n")
      validate_front_matter(front_matter)
      parsed_yaml <- yaml_load_utf8(front_matter)
      if (is.list(parsed_yaml))
        parsed_yaml
      else
        list()
    }
    else
      list()
  }
  else
    list()
}

validate_front_matter <- function(front_matter) {
  front_matter <- trim_trailing_ws(front_matter)
  if (grepl(":$", front_matter))
    stop("Invalid YAML front matter (ends with ':')", call. = FALSE)
}

partition_yaml_front_matter <- function(input_lines) {

  validate_front_matter <- function(delimiters) {
    if (length(delimiters) >= 2 &&
        (delimiters[2] - delimiters[1] > 1) &&
        grepl("^---\\s*$", input_lines[delimiters[1]])) {
      # verify that it's truly front matter (not preceded by other content)
      if (delimiters[1] == 1)
        TRUE
      else
        is_blank(input_lines[1:delimiters[1]-1])
    } else {
      FALSE
    }
  }

  # is there yaml front matter?
  delimiters <- grep("^(---|\\.\\.\\.)\\s*$", input_lines)
  if (validate_front_matter(delimiters)) {

    front_matter <- input_lines[(delimiters[1]):(delimiters[2])]

    input_body <- c()

    if (delimiters[1] > 1)
      input_body <- c(input_body,
                      input_lines[1:delimiters[1]-1])

    if (delimiters[2] < length(input_lines))
      input_body <- c(input_body,
                      input_lines[-(1:delimiters[2])])

    list(front_matter = front_matter,
         body = input_body)
  }
  else {
    list(front_matter = NULL,
         body = input_lines)
  }
}


####

# utility function to ensure that 'input' is a valid directory
# (converts from file to parent directory as necessary)
input_as_dir <- function(input) {

  # ensure the input dir exists
  if (!file.exists(input)) {
    stop("The specified directory '", normalize_path(input, mustWork = FALSE),
         "' does not exist.", call. = FALSE)
  }

  # convert from file to directory if necessary
  if (!dir_exists(input))
    input <- dirname(input)

  # return it
  input
}

# return a string as a tempfile
as_tmpfile <- function(str, prefix = "rmarkdown-str") {
  if (length(str) > 0) {
    str_tmpfile <- tempfile(prefix, fileext = ".html")
    writeLines(str, str_tmpfile, useBytes =  TRUE)
    str_tmpfile
  } else {
    NULL
  }
}

dir_exists <- function(x) {
  utils::file_test('-d', x)
}

file_with_ext <- function(file, ext) {
  paste(tools::file_path_sans_ext(file), ".", ext, sep = "")
}


read_lines_utf8 <- function(file, encoding) {

  # read the file
  lines <- readLines(file, warn = FALSE)

  # convert to utf8
  to_utf8(lines, encoding)
}

to_utf8 <- function(x, encoding) {
  # normalize encoding to iconv compatible form
  if (identical(encoding, "native.enc"))
    encoding <- ""

  # convert to utf8
  if (!identical(encoding, "UTF-8"))
    iconv(x, from = encoding, to = "UTF-8")
  else
    mark_utf8(x)
}


# mark the encoding of character vectors as UTF-8
mark_utf8 <- function(x) {
  if (is.character(x)) {
    Encoding(x) <- 'UTF-8'
    return(x)
  }
  if (!is.list(x)) return(x)
  attrs <- attributes(x)
  res <- lapply(x, mark_utf8)
  attributes(res) <- attrs
  names(res) <- mark_utf8(names(res))
  res
}


knitr_files_dir <- function(file) {
  paste(tools::file_path_sans_ext(file), "_files", sep = "")
}

trim_trailing_ws <- function (x) {
  sub("\\s+$", "", x)
}


# utility function to copy all files into the _site directory
copy_site_resources <- function(input, encoding = getOption("encoding")) {

  # get the site config
  config <- site_config(input, encoding)

  if (config$output_dir != ".") {

    # get the list of files
    files <- copyable_site_resources(input = input,
                                     config = config,
                                     recursive = FALSE,
                                     encoding = encoding)

    # perform the copy
    output_dir <- file.path(input, config$output_dir)
    file.copy(from = file.path(input, files),
              to = output_dir,
              recursive = TRUE)
  }
}

# utility function to list the files that should be copied
copyable_site_resources <- function(input,
                                    config = site_config(input, encoding),
                                    recursive = FALSE,
                                    encoding = getOption("encoding")) {

  # get the original file list (we'll need it to apply includes)
  all_files <- list.files(input, all.files = TRUE)

  # excludes:
  #   - known source/data extensions
  #   - anything that starts w/ '.' or '_'
  #   - rsconnect and packrat directories
  #   - user excludes
  extensions <- c("R", "r", "S", "s",
                  "Rmd", "rmd", "md", "Rmarkdown", "rmarkdown",
                  "Rproj", "rproj",
                  "RData", "rdata", "rds")
  extensions_regex <- utils::glob2rx(paste0("*.", extensions))
  excludes <- c("^rsconnect$", "^packrat$", "^\\..*$", "^_.*$", "^.*_cache$",
                extensions_regex,
                utils::glob2rx(config$exclude))
  # add ouput_dir to excludes if it's not '.'
  if (config$output_dir != '.')
    excludes <- c(excludes, config$output_dir)
  files <- all_files
  for (exclude in excludes)
    files <- files[!grepl(exclude, files)]

  # allow back in anything specified as an explicit "include"
  includes <- utils::glob2rx(config$include)
  for (include in includes) {
    include_files <- all_files[grepl(include, all_files)]
    files <- unique(c(files, include_files))
  }

  # if this is recursive then we need to blow out the directories
  if (recursive) {
    recursive_files <- c()
    for (file in files) {
      file_path <- file.path(input, file)
      if (dir_exists(file_path)) {
        dir_files <- file.path(list.files(file_path,
                                          full.names = FALSE,
                                          recursive = TRUE))
        dir_files <- file.path(file, dir_files)
        recursive_files <- c(recursive_files, dir_files)
      } else {
        recursive_files <- c(recursive_files, file)
      }
    }
    recursive_files
  } else {
    files
  }
}

# the yaml UTF-8 bug has been fixed https://github.com/viking/r-yaml/issues/6
# but yaml >= 2.1.14 Win/Mac binaries are not available for R < 3.2.0, so we
# still need the mark_utf8 trick
#' @importFrom utils packageVersion
yaml_load_utf8 <- function(string, ...) {
  string <- paste(string, collapse = '\n')
  if (packageVersion('yaml') >= '2.1.14') {
    yaml::yaml.load(string, ...)
  } else {
    mark_utf8(yaml::yaml.load(enc2utf8(string), ...))
  }
}

yaml_load_file_utf8 <- function(input, ...) {
  yaml_load_utf8(readLines(input, encoding = 'UTF-8'), ...)
}

####


# Most (if not all) from github.com/rstudio/rmarkdown

from_rmarkdown <- function (implicit_figures = TRUE, extensions = NULL) {
  extensions <- paste0(extensions, collapse = "")
  extensions <- gsub(" ", "", extensions)
  if (!implicit_figures && !grepl("implicit_figures", extensions))
    extensions <- paste0("-implicit_figures", extensions)
  rmarkdown_format(extensions)
}

from_rst <-function (extensions = NULL) {
    format <- c("rst")
    addExtension <- function(extension) {
        if (length(grep(extension, extensions)) == 0)
            format <<- c(format, paste0("+", extension))
    }
    addExtension("autolink_bare_uris")
    addExtension("ascii_identifiers")
    addExtension("tex_math_single_backslash")
    format <- c(format, extensions, recursive = TRUE)
    paste(format, collapse = "")
}

pandoc_html_highlight_args <- function (highlight, template, self_contained,
                                        files_dir, output_dir)  {
  args <- c()
  if (is.null(highlight)) {
    args <- c(args, "--no-highlight")
  }
  else if (!identical(template, "default")) {
    if (identical(highlight, "default"))
      highlight <- "pygments"
    args <- c(args, "--highlight-style", highlight)
  }
  else {
    highlight <- match.arg(highlight, html_highlighters())
    if (highlight %in% c("default", "textmate")) {
      highlight_path <- system.file("rmd/h/highlight", package = "rmarkdown")
      if (self_contained)
        highlight_path <- pandoc_path_arg(highlight_path)
      else {
        highlight_path <- normalized_relative_to(output_dir,
                                                 render_supporting_files(highlight_path, files_dir))
      }
      args <- c(args, "--no-highlight")
      args <- c(args, "--variable", paste("highlightjs=",
                                          highlight_path, sep = ""))
      if (identical(highlight, "textmate")) {
        args <- c(args, "--variable", paste("highlightjs-theme=",
                                            highlight, sep = ""))
      }
    }
    else {
      args <- c(args, "--highlight-style", highlight)
    }
  }
  args

}

html_highlighters <- function () { c(highlighters(), "textmate") }
highlighters <- function ()  {
  c("default", "tango", "pygments", "kate", "monochrome", "espresso",
    "zenburn", "haddock")
}

normalized_relative_to <- function (dir, file) {
  relative_to(normalizePath(dir, winslash = "/", mustWork = FALSE),
              normalizePath(file, winslash = "/", mustWork = FALSE))
}

normalize_path <- function (path) {
  if (is.null(path))
    NULL
  else normalizePath(path, winslash = "/", mustWork = FALSE)
}




#' @export
str_tpl_format <- function(tpl, l){
  if("list" %in% class(l)){
    listToNameValue <- function(l){
      mapply(function(i,j) list(name = j, value = i), l, names(l), SIMPLIFY = FALSE)
    }
    f <- function(tpl,l){
      gsub(paste0("{",l$name,"}"), l$value, tpl, fixed = TRUE)
    }
    return( Reduce(f,listToNameValue(l), init = tpl))
  }
  if("data.frame" %in% class(l)){
    myTranspose <- function(x) lapply(1:nrow(x), function(i) lapply(l, "[[", i))
    return( unlist(lapply(myTranspose(l), function(l, tpl) str_tpl_format(tpl, l), tpl = tpl)) )
  }
}
