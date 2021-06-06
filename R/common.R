ticker <- function(object, ticker) {
  UseMethod("ticker")
}
observation.start <- function(object) {
  UseMethod("observation.start")
}
date.from <- function(object) {
  UseMethod("date.from")
}
previous.date.till <- function(object) {
  UseMethod("previous.date.till")
}
date.till <- function(object) {
  UseMethod("date.till")
}

url <- function(object) {
  UseMethod("url")
}

cbr.ticker <- function(object) {
  UseMethod("cbr.ticker")
}


download.ts.chunk <- function(object) {
  UseMethod("download.ts.chunk")
}
download.ts <- function(object) {
  UseMethod("download.ts")
}
use.archive <- function(object) {
  UseMethod("use.archive")
}

write.ts <- function(object) {
  UseMethod("write.ts")
}

freq <- function(object) {
  UseMethod("freq")
}
oecd.ticker <- function(object) {
  UseMethod("oecd_ticker")
}


#' Title
#'
#' @slot ticker character.
#' @slot observation_start Date.
#' @slot previous_date_till Date.
#' @slot date_from Date.
#' @slot ts data.frame.
#'
#' @return
#' @export
#'
#' @examples
setClass("parsed_ts",
  slots = list(
    ticker = "character",
    observation_start = "Date",
    use_archive = 'logical',
    previous_date_till = "Date",
    date_from = "Date",
    ts = "data.frame"
  )
)

setMethod(
  "initialize", "parsed_ts",
  function(.Object,
           ticker,
           observation_start,
           use_archive,
           date_from,
           ts) {
    .Object@ticker <- character()
    .Object@observation_start <- lubridate::ymd()
    .Object@use_archive <- logical()
    .Object@previous_date_till <- lubridate::ymd()
    .Object@date_from <- lubridate::ymd()
    .Object@ts <- tibble::tibble(
      date = lubridate::ymd(),
      value = numeric(),
      update_date = lubridate::ymd()
    )
    validObject(.Object)
    return(.Object)
  }
)

setMethod(
  "ticker", "parsed_ts",
  function(object, ticker) {
    object@ticker <- ticker
    validObject(object)
    return(object)
  }
)


setMethod(
  "observation.start", "parsed_ts",
  function(object) {
    object@observation_start <- macroparsing::variables %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$observation_start %>%
      lubridate::ymd()
    validObject(object)
    return(object)
  }
)

setMethod(
  "use.archive", "parsed_ts",
  function(object) {
    object@use_archive <- macroparsing::variables %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$use_archive
    validObject(object)
    return(object)
  }
)

setMethod(
  "previous.date.till", "parsed_ts",
  function(object) {
    object@previous_date_till <-
      data.table::fread(paste0(Sys.getenv('directory'),
                                           "/data/raw/",
                                           object@ticker,
                                           ".csv"),
      select = "date"
    ) %>%
      .$date %>%
      .[length(.)] %>%
      lubridate::ymd()

    validObject(object)
    return(object)
  }
)

setMethod(
  "write.ts", "parsed_ts",
  function(object) {
    if(object@use_archive&object@observation_start==object@date_from){
      object@ts <- data.table::rbindlist(list(
        eval(parse(text = paste0('macroparsing:::archive_',object@ticker))),
        object@ts
      )) %>%
        dplyr::arrange(
          date, update_date
        )
    }

    data.table::fwrite(object@ts,
                       file = paste0(Sys.getenv('directory'), '/data/raw/',object@ticker,
                                     ".csv"),
                       append = TRUE)
    validObject(object)
    return(object)
  }
)

setMethod("date.from", "parsed_ts",
          function(object
          ) {

            if(nrow(object@ts)==0){
              date_from <- object@previous_date_till


            } else {
              date_from <- object@ts %>%
                .[nrow(.),] %>%
                .$date
            }

            if(length(date_from)==0){
              object@date_from <- object@observation_start %>%
                lubridate::ymd()
            } else {
              object@date_from <- date_from %>%
                lubridate::ymd()
            }
            validObject(object)
            return(object)
          }
)

