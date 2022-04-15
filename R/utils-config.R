#' Set environment variables
#'
#' Создает в домашней директории файл .Renviron с глобальными переменными окружения.
#'
#' @param path character путь к рабочей директории
#' @param fredr_api_key character ключ FREDR API
#'
#' @export
set.environment <- function(path,
                            fredr_api_key){
  # create .Renviron file ----
  message('Создание файла с глобальными переменными')
  text <- paste0("fredr_api_key=",fredr_api_key,
                 "\ndirectory=",path)
  file.create(paste0(Sys.getenv("HOME"), '/.Renviron'))
  write(text,file=paste0(Sys.getenv("HOME"), '/.Renviron'))
  if(file.exists(paste0(Sys.getenv("HOME"), '/.Renviron'))){
    message(paste0('Файл с глобальными переменными успешно создан: ', paste0(Sys.getenv("HOME"), '/.Renviron')))
  } else {
    warning(paste0('Не удалось создать файл с глобальными переменными: ',
                   paste0(Sys.getenv("HOME"), '/.Renviron')))
  }

}
check.files.by.ticker <- function(ticker){
  dirs <- paste0(Sys.getenv("directory"),
                 c("/data/raw",
                   "/data/tf"))

  for(diri in dirs){
    if(!dir.exists(diri)){
      dir.create(diri,
                 showWarnings = FALSE,
                 recursive = TRUE)
    }
  }

  files <- paste0(dirs,"/", ticker, ".csv")

  template <- tibble::tibble(date = character(),
                             value = numeric(),
                             update_date = character())

  for(filei in files){
    if(!file.exists(filei)){

      data.table::fwrite(template,
                         file = filei)
    }
  }
}

check.table <- function(table){
  dir <- paste0(Sys.getenv("directory"),
                "/data/raw_excel/",
                table)

  if(!dir.exists(dir)){
    dir.create(dir,
               showWarnings = TRUE,
               recursive = TRUE)
  }
}

check.log.file <- function(log_file){

    Sys.setenv("log_file"=
               paste0(Sys.getenv('directory'),
                      '/data/log/',
                      format(Sys.time(),
                             '%Y_%m_%d_%H_%M_%S'),
                      '.log'))

  dir <- paste0(Sys.getenv("directory"),
                "/data/log")

  if(!dir.exists(dir)){
    dir.create(dir,
               showWarnings = TRUE,
               recursive = TRUE)
  }

}
