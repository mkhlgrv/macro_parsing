#' check.directory
#'
#' @param actual_directory
#'
#' @return
#' @export
#'
#' @examples
check.directory <- function(actual_directory = NULL){
  if(is.null(actual_directory)){
    actual_directory <- Sys.getenv('directory')
  }
  dir.create(actual_directory,
             showWarnings = FALSE)
  dir.create(paste0(actual_directory, '/data/raw'),
             showWarnings = FALSE,
             recursive = TRUE) # сюда добавить все остальные директории если требуются
  check.raw.files(actual_directory = actual_directory)

}
#' check.raw.files
#'
#' @param actual_directory
#'
#' @return
#' @export
#'
#' @examples
check.raw.files <- function(actual_directory=NULL){
  if(is.null(actual_directory)){
    actual_directory <- Sys.getenv('directory')
  }
  list_files <- list.files(actual_directory)
  data.table::fread(system.file("extdata/info/var_list.csv",
                                package = "macroparsing"),
                    encoding = 'UTF-8',
                    select = 'ticker') %>%
    .$ticker %>%
    paste0(".csv") %>%
    .[which(!.%in% list_files)] %>%
    purrr::walk(function(filei){
      data.table::fwrite(tibble::tibble(date = character(),
                                value = numeric(),
                                update_date = character()),
                         file = (paste0(actual_directory,  '/data/raw/',
                                       filei))
                         )
    })
}

#' Title
#'
#' @param path character.
#' @param fredr_api_key character.
#'
#' @return
#' @export
#'
#' @examples
set.environment <- function(path = "C:/Users/mkhlgrv/Documents/macroparsing_usage",
                            fredr_api_key='aaa'){
  # create directories ----
  dir.create(path = path, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = paste0(path, '/data'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/raw_excel'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/raw'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/out'), showWarnings = FALSE)

  # create .Renviron file ----
  text <- paste0("fredr_api_key=",fredr_api_key,
  "\ndirectory=",path)
  file.create(paste0(path, '/.Renviron'))
  write(text,file=paste0(path, '/.Renviron'))

}

