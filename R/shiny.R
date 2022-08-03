#' @rdname learnr_elements
#' @name learnr_elements
#'
#' @title Learnr addon elements
#'
#' @description
#' The following are helper element for learnr tutorials, that could extend the functionality of learnR
#'
#' Note that when including these functions in a learnr Rmd document it is necessary that
#' the logic functions, `*_logic()`, be included in an R chunk where `context="server"` as
#' they interact with the underlying Shiny functionality. Conversely, any of the ui functions,
#' `*_ui()`, must *not* be included in an R chunk with a `context`. Both types of functions
#' have been written to provide useful feedback if they detect they are in the wrong R chunk
#' type.
#'
NULL

#' @rdname learnr_elements
#' @description Show a question review table
#' @export
review_table = function(){
  tags$div(`id` = "vlab_review")
}

#' @rdname learnr_elements
#' @description Note element that show a note block
#' @export
note = function(text) {
  tags$div(
    HTML(paste0("<div class=\"admonition admonition-note alert alert--secondary\"><div class=\"admonition-heading\"><h5><span class=\"admonition-icon\"><svg xmlns=\"http://www.w3.org/2000/svg\" width=\"14\" height=\"16\" viewBox=\"0 0 14 16\"><path fill-rule=\"evenodd\" d=\"M6.3 5.69a.942.942 0 0 1-.28-.7c0-.28.09-.52.28-.7.19-.18.42-.28.7-.28.28 0 .52.09.7.28.18.19.28.42.28.7 0 .28-.09.52-.28.7a1 1 0 0 1-.7.3c-.28 0-.52-.11-.7-.3zM8 7.99c-.02-.25-.11-.48-.31-.69-.2-.19-.42-.3-.69-.31H6c-.27.02-.48.13-.69.31-.2.2-.3.44-.31.69h1v3c.02.27.11.5.31.69.2.2.42.31.69.31h1c.27 0 .48-.11.69-.31.2-.19.3-.42.31-.69H8V7.98v.01zM7 2.3c-3.14 0-5.7 2.54-5.7 5.68 0 3.14 2.56 5.7 5.7 5.7s5.7-2.55 5.7-5.7c0-3.15-2.56-5.69-5.7-5.69v.01zM7 .98c3.86 0 7 3.14 7 7s-3.14 7-7 7-7-3.12-7-7 3.14-7 7-7z\"></path></svg></span>note</h5></div><div class=\"admonition-content\"><p>",text,"</p></div></div>"))
  )
}

#' @rdname learnr_elements
#' @description Button that used to print the lab, must used with print_button_logic()
#' @export
print_button = function(){
  tags$div(shiny::actionButton("vlab_print", "Print Lab"))
}


#' @rdname learnr_elements
#' @description On click listener for print_button()
#' @export
print_button_logic = function(){
  p = parent.frame()
  local({
    shiny::observeEvent(input$print,
                        {
                          session$sendCustomMessage("print_lab", "") #invoke the vlab-js lib to print the lab
                        })
  }, envir = p)
}
