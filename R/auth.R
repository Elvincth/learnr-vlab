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


