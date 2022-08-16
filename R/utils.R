init_options <- function() {
  set_option(option_name = "vlab.title")
  set_option(option_name = "vlab.api_url", env_name = "API_URL")
  set_option(option_name = "vlab.course_code", env_name = "COURSE_CODE")
  set_option(option_name = "vlab.id")
  set_option(option_name = "vlab.keycloak_url", env_name = "KEYCLOAK_URL")
  set_option(option_name = "vlab.keycloak_client_id", env_name = "KEYCLOAK_CLIENT_ID")
  set_option(option_name = "vlab.keycloak_realm", env_name = "KEYCLOAK_REALM")
}

is_shiny_app <- function() {
  # Make sure to not load shiny as a side-effect of calling this function.
  isNamespaceLoaded("shiny") && shiny::isRunning()
}

is_hosted_app <- function() {
  nzchar(Sys.getenv("SHINY_SERVER_VERSION")) && is_shiny_app()
}

is_shiny_runtime <- function() {
  isTRUE(grepl("^shiny", knitr::opts_knit$get("rmarkdown.runtime")))
}


#' Set options and check option
#' If env_name is set,the function will check if the env var or option is defined
#' if env_name is not set, it will just check is the option is defined
#' this set_option util only required for
#' @keywords internal
set_option <- function(option_name = NULL, env_name = NULL, default = NULL) {
  # if env_name is set, check if the env var is defined\
  # option can be set by environment variable
  if (!is.null(env_name)) {
    env_var <- Sys.getenv(env_name)
    if (!is.null(env_var) && env_var != "") {
      options(option_name = env_var)
    } else if (is.null(getOption(option_name))) {
      if (!is.null(default)) {
        options(option_name = default)
      } else {
        stop(
          paste0(
            "[VLAB] please set the environment variable ",
            env_name,
            " or option ",
            option_name, "\n"
          )
        )
      }
    }
  } else {
    # option cannot be set by environment variable
    if (is.null(getOption(option_name))) {
      if (!is.null(default)) {
        options(option_name = default)
      } else {
        stop(paste0("[VLAB] please set the option ", option_name, "\n"))
      }
    }
  }
}

#' Get yaml header metadata
#'
#' @return Return the yaml_front_matter
#' @keywords internal

metadata <- function() {
  metadata <- list()

  # only run in Rstudio
  if (!is.null(get_tutorial_path())) {
    tutorial_path <- get_tutorial_path()
    metadata <- rmarkdown::yaml_front_matter(tutorial_path)
    learnr::tutorial_options(exercise.reveal_solution = identical(metadata$vlab$mode, "lab"))

    # # TODO allow vlab.api_url and vlab.course_code to be fill in using ENV vars


    # # set the default options from yaml header
    # options(
    #   vlab.api_url = metadata$vlab$api_url,
    #   vlab.course_code = metadata$vlab$course_code,
    #   vlab.id = metadata$vlab$id,
    #   vlab.keyclaok_url = "https://auth.vl.comp.polyu.edu.hk/auth",
    #   vlab.keyclaok_client_id = "vlab-portal-frontend",
    #   vlab.keyclaok_realm = "vlab-test"
    # )


    # # disable all solution if in quiz mode
    # learnr::tutorial_options(exercise.reveal_solution = identical(metadata$vlab$mode, "lab"))

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
  } else {
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
  ))) {
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
