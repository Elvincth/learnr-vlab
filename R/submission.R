access_token <- "" #store the access token of the user

#' Listen to the vlabjs that pass the access token to R
#' See: https://shiny.rstudio.com/articles/communicating-with-js.html
#'
#' @noRd
register_access_token_listener <- function()
{
  p = parent.frame()
  local({
    shiny::observeEvent(session$input$vlab_access_token, {
      # access_token <<- session$input$vlab_access_token

      assign("access_token",
             session$input$vlab_access_token,
             envir = packageEnv)
      cat("vlab: access token recived",
          get("access_token", envir = packageEnv))
    })
  }, envir = p)
}

sumbit_data <- function(my_data, object_id, type) {
  api_url <- getOption("vlab.api_url")
  course_code <- getOption("vlab.course_code")
  assignment_id <- getOption("vlab.id")


  my_body <- list(
    data = jsonlite::toJSON(my_data, force = TRUE),
    objectId = object_id,
    type = type,
    correct = FALSE,
    mark = NULL
  )

  # print("sumbit_data")
  #
  # print(my_data)

  if (!is.null(my_data$feedback$correct)) {
    print("have correct")
    my_body$correct <- my_data$feedback$correct
  }

  if (!is.null(my_data$mark)) {
    my_body$mark <- my_data$mark
  }
#
#   print("req body")
#   print(my_body)

  access_token <-
    paste0("bearer ", get("access_token", envir = packageEnv))

  my_url = paste0(api_url, "/api/submissions/",  course_code, "/", assignment_id)

  print(my_url)

  #print(access_token)

  res <-
    httr::POST(
      url = my_url,
      encode = "json",
      httr::content_type_json(),
      httr::add_headers(Authorization = access_token) ,
      body = my_body
    )

  print("vlab: submit_data")
  print(httr::content(res))

  if (httr::http_error(res)) {
    httr::message_for_status(res)

    showNotification(
      paste("Error while submitting, please try again. Code:", httr::status_code(res), sep=" "),
      duration = 3000,
      type = "error"
    )
  }
}

#' Handle submit tutorial button being click, send api request to the main server
#' See: https://shiny.rstudio.com/articles/communicating-with-js.html
#' @importFrom httr POST
#' @importFrom httr add_headers
#' @importFrom httr content
#' @noRd
register_submit_listener <- function() {
  p = parent.frame()
  local({
    shiny::observeEvent(session$input$vlab_submit,
                        {

                        })

    # if (httr::http_error(res)) {
    #
    # } else {
    #
    # }
  }, envir = p)
}
