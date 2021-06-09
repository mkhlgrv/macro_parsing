

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
           ts = "data.frame",
           url = 'character',
           freq = 'factor',
           transform = 'character',
           deseason = 'character',
           transform.ts = "data.frame",
           deseason.ts = "data.frame"
         )
)


setMethod(
  "initialize", "parsed_ts",
  function(.Object) {
    .Object@observation_start <- lubridate::ymd()
    .Object@previous_date_till <- lubridate::ymd()
    .Object@date_from <- lubridate::ymd()
    .Object@ts <- tibble::tibble(
      date = lubridate::ymd(),
      value = numeric(),
      update_date = lubridate::ymd()
    )
    .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
    validObject(.Object)
    return(.Object)
  }
)

setClass('cbr',
         slots = list(
           cbr_ticker = 'character'
         ),
         contains = 'parsed_ts')


setMethod("initialize", "cbr",
          function(.Object

          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))

            validObject(.Object)
            return(.Object)
          }
)


setClass('dallasfed',
         contains = 'parsed_ts')
setMethod("initialize", "dallasfed",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)
setClass('fred',
         contains = 'parsed_ts')

setMethod("initialize", "fred",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)

setClass('moex',slots = list(date_till = 'Date'),
         contains = 'parsed_ts')

setMethod("initialize", "moex",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            .Object@date_till <- lubridate::ymd()
            validObject(.Object)
            return(.Object)
          }
)



setClass('oecd',
         slots = list(oecd_ticker = 'character'),
         contains = 'parsed_ts')


setMethod("initialize", "oecd",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)
