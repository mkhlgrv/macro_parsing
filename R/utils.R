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

}

#' Create database directory
#'
#' Создает по указанному адресу папку и необходимые подпапки для дальнейшей записи туда базы данных,
#'  а также создает в домашней директории файл .Renviron с глобальными переменными окружения.
#'
#' @param path character путь к рабочей директории
#' @param fredr_api_key character ключ FREDR API
#'
#' @export
set.environment <- function(path,
                            fredr_api_key){
  # create directories ----
  message('Создание рабочей директории')
  dir.create(path = path, showWarnings = FALSE, recursive = TRUE)
  dir.create(path = paste0(path, '/data'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/raw_excel'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/raw'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/tf'), showWarnings = FALSE)
  dir.create(path = paste0(path, '/data/log'), showWarnings = FALSE)

  if(file.exists(path)){
    message(paste0('Рабочая директория успешно создана: ', path))
  } else {
    warning(paste0('Не удалось создать рабочую директорию: ', path))
  }

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


check.files <- function(actual_directory=NULL, type = c('raw', 'transform')){
  type <- match.arg(type)
  if(is.null(actual_directory)){
    actual_directory <- Sys.getenv('directory')
  }
  if(type=="raw"){
    dir.create(paste0(actual_directory, '/data/raw_excel'),
               showWarnings = FALSE,
               recursive = TRUE)
    for(table in rmedb::rosstat_tables$table){
      dir.create(paste0(actual_directory, '/data/raw_excel/', table),
                 showWarnings = FALSE,
                 recursive = TRUE)
    }
  }
  folder_by_type <- type
  if(folder_by_type=="transform"){
    folder_by_type <-  "tf"
  }
  list_files <- list.files(paste0(actual_directory, '/data/',folder_by_type,'/'))
  rmedb::variables %>%
    .$ticker %>%
    paste0(".csv") %>%
    .[which(!.%in% list_files)] %>%
    purrr::walk(function(filei){
      data.table::fwrite(tibble::tibble(date = character(),
                                        value = numeric(),
                                        update_date = character()),
                         file = (paste0(actual_directory,  '/data/',folder_by_type,'/',
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


get.next.weekday <- function(date, day, lead=0){
  library(lubridate)
  date <- as.Date(date)
  out <- Date()
  for(i in 1:length(date)){
    dates <- seq(date[i]+ 7*(lead), date[i] + 7*(lead+1) - 1, by="days")
    out[i] <- dates[lubridate::wday(dates, label=T)==day]
  }
  out
}


russificate.tab <- function(x){
  x %>%
    dplyr::mutate(source = dplyr::recode(source,
                            rosstat = 'Росстат',
                            oecd = 'OECD',
                            fred = 'FRED',
                            cbr = 'Банк России',
                            internal = 'Внутренние расчеты',
                            dallasfed = 'Federal Reserve Bank of Dallas',
                            moex = 'Мосбиржа'
    ),
    freq =
      dplyr::recode(freq,
              d = 'день',
              w = 'неделя',
              m = 'месяц',
              q = 'квартал'
      ))
}

add.href.to.column <- function(x, column){
  x <- x %>% dplyr::as_tibble()
  x[column] <- paste0('<a href="',x[[column]], '">',x[[column]],'</a>')
  x
}

#' Show variables
#'
#' Возвращает data.frame со справочной информацией по переменным, которые доступны для скачивания в пакете.
#'
#' @param additional logical показывать дополнительные колонк
#' @param russificate logical русифицировать названия источников и периодов
#' @param url_as_href logical сделать url-ссылки кликабельными
#'
#' @return data.frame
#' @export
show.variables <- function(additional=FALSE, russificate = FALSE, url_as_href=FALSE){
  out <- rmedb::variables[, c("ticker","name_rus_tf", "source", "freq", "observation_start")]
  if(additional){
    out <- out %>%
      dplyr::left_join(rmedb::additional_info, by = 'ticker')

    if(url_as_href){
      out <- add.href.to.column(out, 'url')
    }
  }
  out <- out %>%
    dplyr::filter(source != 'rosstat1') %>%
    dplyr::arrange(ticker)

  if(russificate){
    out <- out %>%
      russificate.tab()
  }

  data.table::data.table(out)

}





update.log.file <- function(){
  list.files(path = paste0(Sys.getenv("directory"), "/data/raw")) %>%
    purrr::map_dfr(function(filei){
      ticker <- gsub(pattern = ".csv", replacement = "", x = filei)
      log_info <- data.table::fread(paste0(Sys.getenv("directory"), "/data/raw/",filei)) %>%
        dplyr::group_by(update_date) %>%
        dplyr::summarise(n = dplyr::n()) %>%
        dplyr::mutate(ticker = ticker,
                      update_date = as.Date(update_date))
    }) %>%
    data.table::fwrite(file = paste0(Sys.getenv("directory"), "/data/info.csv"))
}


check.bracket <- function(x){
  if(!is.numeric(x)){
    x <- gsub(' ','' ,x)
    x <- gsub('\\d{1}\\)','' ,x)
    x <- gsub(',','\\.' ,x)

  }
  x
}
