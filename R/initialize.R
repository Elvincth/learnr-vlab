packageEnv <- new.env()
api_url <-"" #base api url option e.g."http://localhost:3000" (vlab.course_code)
course_code <- "" #course code option (vlab.api_url)


#init vlabjs client side keycloak auth with others options passed in
vlab_js_init <- function(session)
{
  session$sendCustomMessage("vlab_init", list(
    url = getOption("vlab.keycloak_url"),
    client_id = getOption("vlab.keycloak_client_id"),
    realm = getOption("vlab.keycloak_realm"),
    course_code =  getOption("vlab.course_code"),
    assignment_id = getOption("vlab.id")
  ))
}

#' Initialize the virtual lab package
#' It is called once in zzz.R when the package is being use
#'
#' @keywords internal
initialize_vlab <- function() {
    #weather to disable the vlab package
    isDisable <- getOption("vlab.disable", default = FALSE)

    if (isFALSE(isDisable)) {
      init_options()

      #add new events triggers
      register_new_event_handlers()

      override_question_fn()
      override_setup_exercise_handler()

      #use our own tutorial json storage
      # options(tutorial.storage = json_filesystem_storage())

      # options(tutorial.event_recorder = new_recorder)

      event_register_handler("session_start", function(session, event, data) {
        vlab_js_init(session)
        show_login_model(session)
        health_check(session)
        register_access_token_listener()
        register_submit_listener()
        send_vlab_state_update(session)
        #send_api_url(session)
      })

      event_register_handler("exercise_result", function(session, event, data) {
        if (isTRUE(data$checked)) {
          sumbit_data(data, data$label, "exercise_result")
          send_vlab_state_update(session)
        }
      })

      event_register_handler("exercise_submitted", function(session, event, data) {
        print(paste0("[Event] ", event, data))
        send_vlab_state_update(session)
      })

      event_register_handler("question_submission", function(session, event, data) {
        sumbit_data(data, data$label, "question_submission")
        send_vlab_state_update(session)
      })
    }
}


