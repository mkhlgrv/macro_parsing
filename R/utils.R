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
  check.files(actual_directory = actual_directory, type='raw')
  check.files(actual_directory = actual_directory, type='transform')
  check.files(actual_directory = actual_directory, type='deseason')

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
set.environment <- function(path,
                            fredr_api_key){
  # create directories ----
  dir.create(path = path, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = paste0(path, '/data'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/raw_excel'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/raw'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/transform'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/deseason'), showWarnings = FALSE)

  # create .Renviron file ----
  text <- paste0("fredr_api_key=",fredr_api_key,
  "\ndirectory=",path)
  file.create(paste0(path, '/.Renviron'))
  write(text,file=paste0(path, '/.Renviron'))

}


check.files <- function(actual_directory=NULL, type = c('raw', 'transform', 'deseason')){
  type <- match.arg(type)
  if(is.null(actual_directory)){
    actual_directory <- Sys.getenv('directory')
  }
  list_files <- list.files(paste0(actual_directory, '/data/',type,'/'))
  macroparsing::variables %>%
    .$ticker %>%
    paste0(".csv") %>%
    .[which(!.%in% list_files)] %>%
    purrr::walk(function(filei){
      data.table::fwrite(tibble::tibble(date = character(),
                                        value = numeric(),
                                        update_date = character()),
                         file = (paste0(actual_directory,  '/data/',type,'/',
                                        filei))
      )
    })
}

find.by.pattern <- function(x, pattern){
  if(length(pattern)>0){
    x <- stringr::str_match(string = x,
                            pattern[[1]])[1,2]
    pattern <- pattern[-1]
    find.by.pattern(x, pattern)
  } else {
    x
  }
}

show.variables <- function(){
  macroparsing::variables[, c("ticker", "source", "freq", "name_eng", "name_rus_short", "observation_start")]
}
