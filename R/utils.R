#' Get yaml header metadata
#'
#' @return Return the yaml_front_matter
#' @keywords internal

metadata <- function() {
  metadata <- list()

  #only run in Rstudio
  if (!is.null(get_tutorial_path())) {
    tutorial_path <- get_tutorial_path()
    metadata <- rmarkdown::yaml_front_matter(tutorial_path)
    learnr::tutorial_options(exercise.reveal_solution = identical(metadata$vlab$mode, "lab"))

    #TODO allow vlab.api_url and vlab.course_code to be fill in using ENV vars


    #set the default options from yaml header
    options(
      vlab.api_url = metadata$vlab$api_url,
      vlab.course_code = metadata$vlab$course_code,
      vlab.id = metadata$vlab$id
    )

    if (is.null(getOption("vlab.id")) || getOption("vlab.id") == "") {
      stop("vlab.id cannot be NULL")
    }

    if (is.null(getOption("vlab.course_code")) || getOption("vlab.course_code") == "") {
      stop("vlab.course_code cannot be NULL")
    }

    if (is.null(getOption("vlab.api_url")) || getOption("vlab.api_url") == "") {
      warning("vlab.api_url is NULL, http://localhost:3000 is used")
      options(vlab.api_url = "http://localhost:3000")
    }
  }

  metadata
}

#' Get current tutorial file path
#'
#' @param absolute
#'
#' @return NULL or the absolute path of the tutorial
#' @keywords internal
get_tutorial_path <- function(absolute = TRUE) {
  path <- NULL

  # location of script can depend on how it was invoked:
  # source() and knit() put it in sys.calls()
  if (!is.null(sys.calls())) {
    # get name of script - hope this is consistent!
    path <- as.character(sys.call(1))[2]
    # make sure we got a file that ends in .Rmd Only
  } else{
    # Rscript and R -f put it in commandArgs
    args <- commandArgs(trailingOnly = FALSE)
    path <- args
  }

  if (is.null(path) | is.na(path)) {
    return(NULL)
  }

  if (!(grepl(
    ".+[Rrq][Mm][Dd]$",
    path,
    perl = TRUE,
    ignore.case = TRUE
  )))  {
    return(NULL)
  }

  # expand ~ if any
  path <- normalizePath(path, winslash = "/")

  # if absolute path is requested then return full path
  # otherwise return relative to working directory
  if (!absolute) {
    path <-
      sub(normalizePath(getwd(), winslash = "/"), ".", path, fixed = TRUE)
  }

  return(path)
}
