#' Filesystem-based JSON storage for tutor state data
#'
#' Tutorial state storage handler that uses the filesystem
#' as a backing store. The JSON file will be created in the dir,
#' for saving the tutorial data.
#'
#' @param dir Directory to store state data within
#'
#' @return Storage handler suitable for \code{options(tutorial.storage = ...)}
#'
#' @importFrom jsonlite base64_dec
#' @importFrom jsonlite base64_enc
#' @importFrom jsonlite fromJSON
#' @importFrom jsonlite toJSON
#'
#' @export

json_filesystem_storage <- function() {
  list(
    # save an arbitrary R object "data" to storage
    save_object = function(tutorial_id,
                           tutorial_version,
                           user_id,
                           object_id,
                           data) {
      storage_list <- list()
      storage_path <- get_storage_path()

      #check if have a saved version before, if yes parse it will later join with the new data
      if (file.exists(storage_path)) {
        storage_list <-
          fromJSON(storage_path) #parse json from saved json file
      }

      storage_list[[object_id]] <-
        list(data = base64_enc(serialize(data, connection = NULL)), json = base64_enc(toJSON(data))) #save the data as encoded base64 entry

      exportJSON <-
        jsonlite::minify(toJSON(storage_list))  #export list to JSON object

      write(exportJSON, storage_path) #write to the storage path

    },


    # retreive a single R object from storage
    get_object = function(tutorial_id,
                          tutorial_version,
                          user_id,
                          object_id) {
      storage_path <- get_storage_path()

      if (file.exists(storage_path)) {
        storage_list <-
          fromJSON(storage_path) #parse json from saved json file

        data <-
          storage_list[[object_id]]$data #Get the data value by object_id

        if (is.null(data)) {
          #check if data exists (not null)
          NULL
        } else{
          unserialize(base64_dec(data)) #return the decoded base64 data
        }

      } else{
        NULL
      }
    },


    # retrieve a list of all R objects stored
    get_objects = function(tutorial_id, tutorial_version, user_id) {
      storage_path <- get_storage_path()
      objects <- list()

      if (file.exists(storage_path)) {
        #  print("get_objects")
        storage_list <- fromJSON(storage_path)
        for (object_id in names(storage_list)) {
          objects[[length(objects) + 1]] <-
            unserialize(base64_dec(storage_list[[object_id]]$data))
        }
      }

      # print(objects)

      objects

    },

    # remove all stored R objects json file
    remove_all_objects = function(tutorial_id, tutorial_version, user_id) {
      storage_path <- get_storage_path()

      if (file.exists(storage_path)) {
        unlink(storage_path)
      }
    }
  )
}

#helper to get stored data
get_storage_data <- function() {
  storage_path <- get_storage_path()
  if (file.exists(storage_path)) {
     jsonlite::fromJSON(storage_path)
  }
}

# helper to construct the path that store the json file
get_storage_path <- function() {
  dir = getwd()
  tutorial_info <- learnr::get_tutorial_info()
  #to form a unique tutorial storage id in a base64 form
  storage_id <-
    base64_enc(
      paste(
        tutorial_info$tutorial_id,
        tutorial_info$tutorial_version,
        tutorial_info$user_id,
        sep = "-"
      )
    )
  paste0(dir , "/", storage_id, ".json")
}
