# Get started

All source files are located under the `R` folder.
The `vlab-js` folder is another project, it is the client javascript library for the learnR.

# Development

1. Run `build.R` in the root, it is a post build script.

2. In r studio go to build > install and restart, to install the library for testing.

### Note

For each function we need to apply a roxygen comments (see: https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html), so that method could be documented and internal function won't get exported.

# Features

## Import the library

```
library(polyuvlab)
```

## Configs

Define the mode, lab mode will show the solution, and the lab mode will not.

```
vlab:
  mode: 'quiz' #quiz or lab
```

## Storage

Use the json filesystem storage, which store the tutorial state in a `.json` file, which make it easy to share the state to server.

```
options(tutorial.storage = polyuvlab::json_filesystem_storage())
```

## New events

### topic_viewed

Trigger when the user viewed a topic

similar with `section_view` event

```

topic_viewed

```

## New blocks

### Question with no ack

```

question_no_ack(
"Which planet do we live on?",
answer("Mars", correct = FALSE),
answer("Earth", correct = TRUE),
answer("Saturn", correct = FALSE),
allow_retry = TRUE
)

question_text_no_ack(
"Student Name:",
answer(NULL, correct = TRUE),
incorrect = "Ok",
try_again_button = "Modify your answer",
allow_retry = TRUE
)

```

### note

```{r note}
note("Hello, world")
```

### question review table

```{r, echo=FALSE}
review_table()
```

### print button
```{r context='server', echo=FALSE}
print_button_logic()
```

```{r, echo=FALSE}
print_button()
```
