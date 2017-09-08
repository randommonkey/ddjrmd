

# # create an html dependency for bootstrap (function copied from rmarkdown)
# html_dependency_bootstrap <- function(theme = "bootstrap") {
#   htmltools::htmlDependency(name = "bootstrap",
#                             version = "3.3.6",
#                             src = system.file("templates/bootstrap-3.3.6", package = "rmdformats"),
#                             meta = list(viewport = "width=device-width, initial-scale=1"),
#                             script = c(
#                               "js/bootstrap.min.js"
#                               # These shims are necessary for IE 8 compatibility
#                               #"shim/html5shiv.min.js",
#                               #"shim/respond.min.js"
#                             ),
#                             stylesheet = paste("css/", theme, ".min.css", sep = ""))
# }
#
# # create an html dependency for bootstrap js only (function copied from rmarkdown)
# html_dependency_bootstrap_js <- function() {
#   htmltools::htmlDependency(name = "bootstrap_js",
#                             version = "3.3.6",
#                             src = system.file("templates/bootstrap-3.3.6", package = "rmdformats"),
#                             meta = list(viewport = "width=device-width, initial-scale=1"),
#                             script = c(
#                               "js/bootstrap.min.js"
#                             ))
# }

# # create an html dependency for hamburguers
# html_dependency_hamburguer <- function() {
#   htmltools::htmlDependency(name = "magnific-popup",
#                             version = "1.1.0",
#                             src = system.file("templates/magnific-popup-1.1.0", package = "rmdformats"),
#                             script = "jquery.magnific-popup.min.js",
#                             stylesheet = "magnific-popup.css")
# }
