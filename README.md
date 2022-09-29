
# Get started

## Install the package
```
remotes::install_github('polyu-vlab/vlab')
```

## Import and setup the package

````

```{=html}
<script language="JavaScript" src="https://cdn.jsdelivr.net/gh/polyu-vlab/vlab/inst/dist/vlab_bundle.js"></script>
```

```{r setup, include=FALSE}
options(
  #vlab.disable = TRUE, #weather to disable the vlab package
  vlab.title = "Some title",
  vlab.id = "asm1",
  vlab.api_url = Sys.getenv("API_URL"),
  vlab.course_code = Sys.getenv("COURSE_CODE"),
  vlab.keycloak_url = Sys.getenv("KEYCLOAK_URL"),
  vlab.keycloak_client_id = Sys.getenv("KEYCLOAK_CLIENT_ID"),
  vlab.keycloak_realm = Sys.getenv("KEYCLOAK_REALM")
)

library(vlab)
```
````

# Features

## Storage

Use the json filesystem storage, which store the tutorial state in a `.json` file, which make it easy to share the state to server.

```
options(tutorial.storage = vlab::json_filesystem_storage())
```

## New events

### topic_viewed

Trigger when the user viewed a topic

similar with `section_view` event

```

topic_viewed

```

## Elements

### Quesion review table with print table
````
```{r, echo=FALSE}
print_button()
review_table()
```
````

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

### Note
````
```{r}
note("Hello, world")
```
````


# Development

All source files are located under the `R` folder.
The `vlab-js` folder is another project, it is the client javascript library for the learnR.

1. Run `build.R` in the root, it is a post build script.

2. In r studio go to build > install and restart, to install the library for testing.

### Note

For each function we need to apply a roxygen comments (see: https://cran.r-project.org/web/packages/roxygen2/vignettes/roxygen2.html), so that method could be documented and internal function won't get exported.
