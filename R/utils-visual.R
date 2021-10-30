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
