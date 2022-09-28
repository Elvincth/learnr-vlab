
#update question review table
question_review_update <- function() {
  session <- shiny::getDefaultReactiveDomain()
  access_token <-
    paste0("bearer ", get("access_token", envir = packageEnv))

  my_url = paste0(
    getOption("vlab.api_url"),
    "/api/question-review/",
    getOption("vlab.course_code"),
    "/",
    getOption("vlab.id")
  )

 print(my_url)

  tryCatch({
    res <-
      httr::GET(url = my_url,
                httr::add_headers(Authorization = access_token))

    content <- httr::content(res)

    session$sendCustomMessage("vlab_question_review_update", content)

    #check if the status code is 200, if not throw the error out
    if (httr::http_error(res)) {
      httr::message_for_status(res)
      stop(paste("Code:", httr::status_code(res), " ", content$error, sep = " "))
    }else{
      # shiny::showNotification(paste("Initialize successfully. You can start accepting submissions.", sep = " "),
      #                         duration = 10, type="message")
      #
      # shiny::removeModal() #close the init modal
    }
  },
  error = function(cond) {
    show_error(cond)
  },
  warning = function(cond) {
    show_error(cond)
  })
}
