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
      # cat("vlab: access token recived",
      #     get("access_token", envir = packageEnv))
    })
  }, envir = p)
}



#run health check after auth, check is the assignment ready for submissions
health_check <- function(session){

  shiny::observeEvent(session$input$vlab_authenticated, {
    #print("health_check")
    access_token <-
      paste0("bearer ", get("access_token", envir = packageEnv))

    my_url = paste0(
      getOption("vlab.api_url"),
      "/api/healthcheck/",
      getOption("vlab.course_code"),
      "/",
      getOption("vlab.id")
    )

    tryCatch({
      res <-
        httr::GET(url = my_url,
                  httr::add_headers(Authorization = access_token))

      content <- httr::content(res)

      print(paste0("health_check ", content))


      #check if the status code is 200, if not throw the error out
      if (httr::http_error(res)) {
        httr::message_for_status(res)
        stop(paste("Code:", httr::status_code(res), " ", content, sep = " "))
      } else{
        #Where the asm have not been initialized
        if (isFALSE(content$initialized)) {
          showModal(
            modalDialog(
              title = "Note",
              tags$div(HTML("<h4 style=\"
                            color: #dd1414;
                              font-weight: bold;
                            \">Please initialize the assignment by clicking \"create assignment\", or else the student won't be able to submit it!</h4>")),
              tags$div(HTML("<h4 style=\"
                            color: #1487dd;
                              font-weight: bold;
                            \">Note: Only the course owner can initialize.</h4>")),
              tags$h4(paste0("Title: ", getOption("vlab.title"))),
              tags$h4(paste0("Id: ", getOption("vlab.id"))),
              tags$h4(paste0("Course code: ", getOption("vlab.course_code"))),
              easyClose = TRUE,
              #session$ns is namespaced id
              footer = tagList(actionButton(
                session$ns("vlab_create_asm"), "Create assignment"
              ))
            ),
            session
          )
        }
      }

    },
    error = function(cond) {
      #tell vlabjs to show the error message
      session$sendCustomMessage("vlab_healthcheck_error", "error")
      show_error(cond)
    },
    warning = function(cond) {
      show_warning(cond)
    })
  })


  #on click listener for "Create assignment" button
  shiny::observeEvent(session$input$vlab_create_asm,
                      {
                        create_assignment()
                      })
}

#create the assignment in dashboard
create_assignment <- function() {
  access_token <-
    paste0("bearer ", get("access_token", envir = packageEnv))

  my_url = paste0(
    getOption("vlab.api_url"),
    "/api/assignments/create/",
    getOption("vlab.course_code"),
    "/",
    getOption("vlab.id")
  )

  #print(access_token)
  tryCatch({
    res <-
      httr::POST(
        url = my_url,
        encode = "json",
        httr::content_type_json(),
        httr::add_headers(Authorization = access_token) ,
        body = list(
          assignmentName = getOption("vlab.title")
        )
      )

    content <- httr::content(res)

    #check if the status code is 200, if not throw the error out
    if (httr::http_error(res)) {
      httr::message_for_status(res)
      stop(paste("Code:", httr::status_code(res), " ", content$error, sep = " "))
    }else{
      shiny::showNotification(paste("Initialize successfully. You can start accepting submissions.", sep = " "),
                              duration = 10, type="message")

      shiny::removeModal() #close the init modal
    }
  },
  error = function(cond) {
    show_error(cond)
  },
  warning = function(cond) {
    show_error(cond)
  })
}

show_warning <- function(msg, duration = 10) {
  showNotification(
    paste("Warning: ", msg, sep = " "),
    duration = duration,
    type = "warning"
  )
}

show_error <- function(msg, duration = 10) {
  showNotification(
    paste("Error occur: ", msg, sep = " "),
    duration = duration,
    type = "error"
  )
}


#handle submit data
sumbit_data <- function(my_data, object_id, type) {
  api_url <- getOption("vlab.api_url")
  course_code <- getOption("vlab.course_code")
  assignment_id <- getOption("vlab.id")
  access_token <-
    paste0("bearer ", get("access_token", envir = packageEnv))


  my_body <- list(
    data = jsonlite::toJSON(my_data, force = TRUE),
    objectId = object_id,
    type = type,
    correct = FALSE,
    mark = NULL
  )


  print("my_body")

  print(my_body)

  if (!is.null(my_data$feedback$correct)) {
    print("have correct")
    my_body$correct <- my_data$feedback$correct
  }

  if (!is.null(my_data$mark)) {
    my_body$mark <- my_data$mark
  }



  my_url = paste0(api_url,
                  "/api/submissions/",
                  course_code,
                  "/",
                  assignment_id)

  print(my_url)

  #print(access_token)
  tryCatch({
    res <-
      httr::POST(
        url = my_url,
        encode = "json",
        httr::content_type_json(),
        httr::add_headers(Authorization = access_token) ,
        body = my_body
      )

    content <- httr::content(res)
    print("vlab: submit_data")
    print(content)

    #check if the status code is 200, if not throw the error out
    if (httr::http_error(res)) {
      httr::message_for_status(res)
      stop(paste("Code:", httr::status_code(res), " ", content$error, sep = " "))
    }else{
      shiny::showNotification(paste("Submit successfully.", sep = " "),
                       duration = 10, type="message")
    }
  },
  error = function(cond) {
    show_submission_error_msg(cond)
  },
  warning = function(cond) {
    show_submission_error_msg(cond)
  })
}

#display error message
show_submission_error_msg <- function(msg, duration = 10) {
  showNotification(
    paste("Error while submitting, please try again. ", msg, sep = " "),
    duration = duration,
    type = "error"
  )
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
