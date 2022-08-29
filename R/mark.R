install_mark_knitr_hooks <- function() {
  #store all the questions with mark in format e.g. mark_question_label$`label` = 10

  #register an option hook which triggers when mark
  #see: https://bookdown.org/yihui/rmarkdown-cookbook/option-hooks.html
  knitr::opts_hooks$set(
    mark = function(options) {
      label <- knitr::opts_current$get(name = "label")
      #test if the mark option is valid
      if (!grepl("^[0-9]{1,}$", options$mark)) {
        stop(paste0("error in ", label, " mark option must be NUMBER!"))
      }
      options
    }
  )
}

override_setup_exercise_handler = function() {
  # run an exercise and return HTML UI
  setup_exercise_handler <- function(exercise_rx, session) {

    # get the environment where shared setup and data is located. one environment up
    # includes all of the shiny housekeeping (e.g. inputs, output, etc.); two
    # environments up will be an empty environment
    # (https://github.com/rstudio/rmarkdown/blob/54bf8fc70122c6a435bba2ffcac8944d04498541/R/shiny_prerendered.R#L10)
    # that is parented by the shiny_prerendered server_envir (which has all of
    # the shared setup, data chunks executed).
    server_envir <- parent.env(parent.env(parent.frame()))

    # setup reactive values for return
    rv <- reactiveValues(triggered = 0, result = NULL)

    # observe input
    observeEvent(exercise_rx(), {

      # get exercise from app
      exercise <- exercise_rx()
      # Add tutorial information
      exercise$tutorial <- get_tutorial_info()
      # Remove tutorial items from exercise object
      exercise$tutorial$items <- NULL

      # short circuit for restore (we restore some outputs like errors so that
      # they are not re-executed when bringing the tutorial back up)
      if (exercise$restore) {
        if (
          getOption(
            "tutorial.quick_restore",
            identical(Sys.getenv("TUTORIAL_QUICK_RESTORE", "0"), "1")
          )
        ) {
          # don't evaluate at all if quick_restore is enabled
          rv$result <- list()
          return()
        }

        object <- get_exercise_submission(session = session, label = exercise$label)
        if (!is.null(object) && !is.null(object$data$output)) {
          # restore user state, but don't report correct
          # since the user's code wasn't re-evaluated
          restored_state <- list(
            type = "exercise",
            answer = object$data$code,
            correct = NA
          )
          set_tutorial_state(exercise$label, restored_state, session = session)

          # get the output
          output <- object$data$output

          # ensure that html dependencies only reference package files
          dependencies <- htmltools::htmlDependencies(output)
          if (!is.null(dependencies))
            htmltools::htmlDependencies(output) <- filter_dependencies(dependencies)

          # assign to rv and return
          rv$result <- output
          return()
        }
      }

      # get exercise evaluator factory function (allow replacement via global option)
      evaluator_factory <- getOption("tutorial.exercise.evaluator", default = NULL)
      if (is.null(evaluator_factory)) {
        remote_host <- getOption("tutorial.external.host", Sys.getenv("TUTORIAL_EXTERNAL_EVALUATOR_HOST", NA))
        if (!is.na(remote_host)){
          evaluator_factory <- external_evaluator(remote_host)
        } else if (!is_windows() && !is_mac())
          evaluator_factory <- forked_evaluator_factory
        else
          evaluator_factory <- inline_evaluator
      }

      # retrieve exercise cache information:
      # - chunks (setup + exercise) for the exercise to be processed in `evaluate_exercise`
      # - checker code (check, code-check, error-check)
      # - solution
      # - engine
      exercise <- append(exercise, get_exercise_cache(exercise$label))

      check_was_requested <- exercise$should_check
      # remove "should_check" item from exercise for legacy reasons, it's inferred downstream
      exercise$should_check <- NULL

      if (!isTRUE(check_was_requested)) {
        exercise$check <- NULL
        exercise$code_check <- NULL
        exercise$error_check <- NULL
      }

      # get timelimit option (either from chunk option or from global option)
      timelimit <- exercise$options$exercise.timelimit
      if (is.null(timelimit))
        timelimit <- getOption("tutorial.exercise.timelimit", default = 30)

      # placeholder for current learnr version to deal with exercise structure differences
      # with other learnr versions
      exercise$version <- current_exercise_version

      # create a new environment parented by the global environment
      # transfer all of the objects in the server_envir (i.e. setup and data chunks)
      envir <- duplicate_env(server_envir, parent = globalenv())
      if (exists(".server_context", envir = envir)) {
        rm(".server_context", envir = envir)
      }

      # create exercise evaluator
      evaluator <- evaluator_factory(evaluate_exercise(exercise, envir),
                                     timelimit, exercise, session)

      # Create exercise ID to map the associated events.
      ex_id <- random_id("lnr_ex")

      # fire event before computing
      event_trigger(
        session,
        "exercise_submitted",
        data = list(
          mark = exercise$options$mark,
          label   = exercise$label,
          id      = ex_id,
          code    = exercise$code,
          restore = exercise$restore
        )
      )

      start <- Sys.time()

      # start it
      evaluator$start()

      # poll for completion
      o <- observe({

        if (evaluator$completed()) {

          # get the result
          result <- evaluator$result()

          # fire event with evaluation result
          event_trigger(
            session,
            "exercise_result",
            data = list(
              label            = exercise$label,
              id               = ex_id,
              mark             = exercise$options$mark,
              code             = exercise$code,
              output           = result$html_output,
              timeout_exceeded = result$timeout_exceeded,
              time_elapsed     = as.numeric(difftime(Sys.time(), start, units="secs")),
              error_message    = result$error_message,
              checked          = check_was_requested,
              feedback         = result$feedback
            )
          )

          # assign reactive result to be sent to the UI
          rv$triggered <- isolate({ rv$triggered + 1})
          rv$result <- exercise_result_as_html(result)

          isolate({
            # update the user_state with this submission, matching the behavior of
            # questions: always update exercises until correct answer is submitted
            current_state <- get_tutorial_state(exercise$label, session = session)
            if (!isTRUE(current_state$correct)) {
              new_state <- list(
                type = "exercise",
                answer = exercise$code,
                correct = result$feedback$correct %||% NA
              )
              set_tutorial_state(exercise$label, new_state, session = session)
            }
          })


          # destroy the observer
          o$destroy()

        } else {
          invalidateLater(100, session)
        }
      })
    })

    # return reactive
    reactive({
      rv$triggered
      req(rv$result)
    })
  }

  environment(setup_exercise_handler) <-
    asNamespace('learnr')
  assignInNamespace("setup_exercise_handler",
                    setup_exercise_handler,
                    ns = "learnr")
}
