#send updated info to vlab.js
send_vlab_state_update <- function() {
  session <- shiny::getDefaultReactiveDomain()
  label <- learnr:::get_tutorial_info(session)$items$label
  session$sendCustomMessage(
    "vlab_state_update",
    list(
      label = label,
      get_all_state_objects = learnr:::get_all_state_objects(session),
      get_tutorial_info = learnr:::get_tutorial_info(session)
    )
  )
}


#' Register new custom events for learnr
#'
#' @import learnr
#' @noRd
register_new_event_handlers <- function() {
  #new topic_viewed event
   event_register_handler(
    "session_start",
    function(session, event, data) {

      # The observer here needs to be registered at session_start; if it is
      # called in initialize_tutorial(), then the "section_viewed" event fire
      # too soon, which will cause errors when it calls get_object(), because
      # the storage system won't yet be ready.
      #
      # This observer watches input$`tutorial-visible-topics`, and wraps it
      # so that it fires a "section_viewed" event when a new section is added
      # to that input value.
      last_visible_topics <- character(0)
      observe({
        visible_topics <- session$input$`tutorial-topic`
        #(session$input$`tutorial-topic`)

        # print(session$input)

        new_visible <- setdiff(visible_topics, last_visible_topics)
        #
        # print(new_visible)
        #

        for (section in new_visible) {
          learnr:::event_trigger(
            session,
            "topic_viewed",
            data = list(topicId = section)
          )
        }

        # Note: `visible_topics` could have more or fewer items from
        # `last_visible_topics`; the setdiff() above only detects if it has
        # more. Always save the `visible_topics`.
        last_visible_topics <<- visible_topics
      })
    }
  )
}
