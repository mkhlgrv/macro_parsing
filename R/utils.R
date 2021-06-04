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
