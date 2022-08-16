packageEnv <- new.env()
api_url <-"" #base api url option e.g."http://localhost:3000" (vlab.course_code)
course_code <- "" #course code option (vlab.api_url)


#' Initialize the virtual lab package
#' It is called once in zzz.R when the package is being use
#'
#' @keywords internal
initialize_vlab <- function() {
  if(is_shiny_runtime()){


    init_options()
  }

  #add new events triggers
  register_new_event_handlers()

  override_question_fn()
  override_setup_exercise_handler()

  #use our own tutorial json storage
 # options(tutorial.storage = json_filesystem_storage())

  # options(tutorial.event_recorder = new_recorder)

  event_register_handler("session_start", function(session, event, data) {
    auth_init(session)
    show_login_model(session)
    register_access_token_listener()
    register_submit_listener()
    send_vlab_state_update()
  })

  event_register_handler("exercise_result", function(session, event, data) {
    if (!is.null(data$feedback)) {
      sumbit_data(data, data$label, "exercise_result")
    }
    send_vlab_state_update()
  })

  event_register_handler("exercise_submitted", function(session, event, data) {
    send_vlab_state_update()
  })

  event_register_handler("question_submission", function(session, event, data) {
    sumbit_data(data, data$label, "question_submission")
    send_vlab_state_update()
  })
}

packageEnv <- new.env()
api_url <-"" #base api url option e.g."http://localhost:3000" (vlab.course_code)
course_code <- "" #course code option (vlab.api_url)


#' Initialize the virtual lab package
#' It is called once in zzz.R when the package is being use
#'
#' @keywords internal
initialize_vlab <- function() {
  if(is_shiny_runtime()){
    init_options()
  }

  #add new events triggers
  register_new_event_handlers()

  override_question_fn()
  override_setup_exercise_handler()


  #use our own tutorial json storage
 # options(tutorial.storage = json_filesystem_storage())

  # options(tutorial.event_recorder = new_recorder)

  event_register_handler("session_start", function(session, event, data) {
    auth_init(session)
    show_login_model(session)
    register_access_token_listener()
    register_submit_listener()
    send_vlab_state_update()
  })

  event_register_handler("exercise_result", function(session, event, data) {
    if (!is.null(data$feedback)) {
      sumbit_data(data, data$label, "exercise_result")
    }
    send_vlab_state_update()
  })

  event_register_handler("exercise_submitted", function(session, event, data) {
    send_vlab_state_update()
  })

  event_register_handler("question_submission", function(session, event, data) {
    sumbit_data(data, data$label, "question_submission")
    send_vlab_state_update()
  })
}

