show_login_model <- function(session) {
  #where we listen to javascript callback to close the modal
  #see: https://shiny.rstudio.com/articles/communicating-with-js.html
  p = parent.frame()
  local({
    shiny::observeEvent(session$input$vlab_close_modal, {
     shiny::removeModal() #close the login modal
    })
  }, envir = p)

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
}

#init vlabjs client side keycloak auth with the options passed in
auth_init <- function(session)
{
  session$sendCustomMessage("auth_init", list(
    url = getOption("vlab.keycloak_url"),
    client_id = getOption("vlab.keycloak_client_id"),
    realm = getOption("vlab.keycloak_realm")
  ))
}
