access_token <- "" #store the access token of the user
logged_in <- FALSE #check if the user is logged in (have access token)

show_login_model <- function(session) {
  #where we listen to javascript callback to close the modal
  #see: https://shiny.rstudio.com/articles/communicating-with-js.html
  p = parent.frame()
  local({
    shiny::observeEvent(session$input$vlab_close_modal, {
     shiny::removeModal() #close the login modal
    })


    shiny::observeEvent(session$input$vlab_open_login_modal, {
      showModal(
        modalDialog(
          title = "Login",
          tags$p("Please login to your vlab account."),
          # textInput("vlab_username", "Username"),
          # passwordInput("vlab_password", "Password:"),
          easyClose = FALSE,
          #session$ns is namespaced id
          footer = tagList(actionButton(session$ns("vlab_login"), "Login"))
        ),
        session
      )
    })
  }, envir = p)
}


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

      if(isFALSE(logged_in)){
        logged_in <- TRUE
        on_logged_in()
      }

      # cat("vlab: access token recived",
      #     get("access_token", envir = packageEnv))
    })
  }, envir = p)
}

#Called once when the user logged in
on_logged_in <- function(){
  #update the question review table once
  question_review_update()
}

