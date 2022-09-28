show_notifcation <- function(message, type = "info", duration = "3000"){
  session <- shiny::getDefaultReactiveDomain()
  session$sendCustomMessage("vlab_notification", list(message = message, type = type, duration = duration))
}
