#No ACK functions



#' Create question with no ACK
#'
#' @param ...
#'
#' @export
#'
#'
#'
  question_no_ack = function(...) {
  #OVERRIDED HERE: set the correct message as vlab.no_ack, tell question_ui_completed.learnr_radio
  question(correct = "vlab.no_ack",
           ...)
}


#' Create question text with no ACK
#'
#' @param ...
#'
#' @export
#'
#'
question_text_no_ack = function(...) {
  #OVERRIDED HERE: set the correct message as vlab.no_ack, tell question_ui_completed.learnr_radio
  question_text(correct = "vlab.no_ack",
           ...)
}


#override the question_module_server_impl function in the learnr package
#overrided code is mark as "OVERRIDED"on top on the code chunk
override_question_fn = function() {
  question_module_server_impl <- function(input,
                                          output,
                                          session,
                                          question,
                                          question_state = NULL) {


    ns <- getDefaultReactiveDomain()$ns
    # set a seed for each user session for question methods to use
    question$seed <- random_seed()

    # only set when a submit button has been pressed
    # (or reset when try again is hit)
    # (or set when restoring)
    submitted_answer <-
      reactiveVal(NULL, label = "submitted_answer")

    is_correct_info <- reactive(label = "is_correct_info", {
      # question has not been submitted
      if (is.null(submitted_answer()))
        return(NULL)
      # find out if answer is right
      ret <- question_is_correct(question, submitted_answer())
      if (!inherits(ret, "learnr_mark_as")) {
        stop(
          "`question_is_correct(question, input$answer)` must return a result from `correct`, `incorrect`, or `mark_as`"
        )
      }
      ret
    })

    # should present all messages?
    is_done <- reactive(label = "is_done", {
      if (is.null(is_correct_info()))
        return(NULL)
      (!isTRUE(question$allow_retry)) || is_correct_info()$correct
    })


    button_type <- reactive(label = "button type", {
      if (is.null(submitted_answer())) {
        "submit"
      } else {
        # is_correct_info() should be valid
        if (is.null(is_correct_info())) {
          stop("`is_correct_info()` is `NULL` in a place it shouldn't be")
        }

        # update the submit button label
        if (is_correct_info()$correct) {
          #OVERRIDED HERE: If question$messages$correct is vlab.no_ack and allow retry, then show try_again
          if (isTRUE(question$allow_retry) &&
              question$messages$correct == "vlab.no_ack") {
            "try_again"
          } else{
            "correct"
          }
        } else {
          # not correct
          if (isTRUE(question$allow_retry)) {
            # not correct, but may try again
            "try_again"
          } else {
            # not correct and can not try again
            "incorrect"
          }
        }
      }
    })

    # disable / enable for every input$answer change
    answer_is_valid <- reactive(label = "answer_is_valid", {
      if (is.null(submitted_answer())) {
        question_is_valid(question, input$answer)
      } else {
        question_is_valid(question, submitted_answer())
      }
    })

    init_question <- function(restoreValue = NULL) {
      if (question$random_answer_order) {
        # Shuffle visible answer options (i.e. static, non-function answers)
        is_visible_option <-
          !answer_type_is_function(question$answers)
        question$answers[is_visible_option] <<-
          shuffle(question$answers[is_visible_option])
      }
      submitted_answer(restoreValue)
    }

    # restore past submission
    #  If no prior submission, it returns NULL
    past_submission_answer <-
      retrieve_question_submission_answer(session, question$label)
    # initialize like normal... nothing has been submitted
    #   or
    # initialize with the past answer
    #  this should cascade throughout the app to display correct answers and final outputs
    init_question(past_submission_answer)


    output$action_button_container <- renderUI({
      question_button_label(question,
                            button_type(),
                            answer_is_valid())
    })

    output$message_container <- renderUI({
      req(!is.null(is_correct_info()), !is.null(is_done()))

      correct <- is_correct_info()$message

      #OVERRIDED if question$messages$correct is vlab.no_ack we will not print the feedback dialog
      if (isTRUE(question$messages$correct != "vlab.no_ack")) {
        withLearnrMathJax(
          question_messages(
            question,
            messages = is_correct_info()$messages,
            is_correct = is_correct_info()$correct,
            is_done = is_done()
          )
        )
      }
    })

    output$answer_container <- renderUI({
      if (is.null(submitted_answer())) {
        # has not submitted, show regular answers
        return(# if there is an existing input$answer, display it.
          # if there is no answer... init with NULL
          # Do not re-render the UI for every input$answer change
          withLearnrMathJax(question_ui_initialize(question, isolate(
            input$answer
          ))))
      }

      # has submitted

      if (is.null(is_done())) {
        # has not initialized
        return(NULL)
      }

      #OVERRIDED if question$messages$correct is vlab.no_ack, do not render the done UI
      if (is_done() &&
          isTRUE(question$messages$correct != "vlab.no_ack")) {
        # if the question is 'done', display the final input ui and disable everything

        return(withLearnrMathJax(question_ui_completed(question, submitted_answer())))
      }

      # if the question is NOT 'done', disable the current UI
      #   until it is reset with the try again button

      return(withLearnrMathJax(question_ui_try_again(question, submitted_answer())))
    })


    observeEvent(input$action_button, {
      if (button_type() == "try_again") {
        # maintain current submission / do not randomize answer order
        # only reset the submitted answers
        # does NOT reset input$xanswer
        submitted_answer(NULL)

        # submit "reset" to server
        event_trigger(
          session,
          "reset_question_submission",
          data = list(
            label    = as.character(question$label),
            question = as.character(question$question)
          )
        )
        return()
      }

      submitted_answer(input$answer)

      # submit question to server
      event_trigger(
        session = session,
        event   = "question_submission",
        data    = list(
          label    = as.character(question$label),
          question = as.character(question$question),
          answer   = as.character(input$answer),
          correct  = is_correct_info()$correct
        )
      )

    })

    observe({
      # Update the `question_state()` reactive to report state back to the Shiny session
      req(submitted_answer(), is.reactive(question_state))
      current_answer_state <- list(
        type = "question",
        answer = submitted_answer(),
        correct = is_correct_info()$correct
      )
      question_state(current_answer_state)
    })
  }

  #override it
  environment(question_module_server_impl) <-
    asNamespace('learnr')
  assignInNamespace("question_module_server_impl",
                    question_module_server_impl,
                    ns = "learnr")

}

