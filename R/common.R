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
           date_from,
           ts) {
    .Object@ticker <- character()
    .Object@observation_start <- lubridate::ymd()
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
    object@observation_start <- data.table::fread(system.file("inst/extdata/info/var_list.csv", package="macroparsing"),
      select = c("ticker", "observation_start")
    ) %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$observation_start %>%
      lubridate::ymd()
    validObject(object)
    return(object)
  }
)

setMethod(
  "previous.date.till", "parsed_ts",
  function(object) {
    object@previous_date_till <-
      data.table::fread(system.file(paste0("inst/extdata/raw/",

                                                                      object@ticker,
                                                                      ".csv"),
                                    package="macroparsing"),
      select = "date"
    ) %>%
      .$date %>%
      .[nrow(.)] %>%
      lubridate::ymd()

    validObject(object)
    return(object)
  }
)

setMethod(
  "write.ts", "parsed_ts",
  function(object) {
    data.table::fwrite(object@ts,
                       file = system.file(paste0("inst/extdata/raw/",
                                                 object@ticker,
                                                 ".csv"),
                                                 package="macroparsing"), append = TRUE)
    validObject(object)
    return(object)
  }
)
