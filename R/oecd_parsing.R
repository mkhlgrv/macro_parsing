#' @include common.R
setClass('oecd',
         slots = list(oecd_ticker = 'character',
                      url = 'character'),
         contains = 'parsed_ts')

setMethod("initialize", "oecd",
          function(.Object,
                   ticker,
                   observation_start,
                   date_from,
                   ts,
                   oecd_ticker
          ) {
            .Object@ticker <- character()
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(date = lubridate::ymd(),
                                         value = numeric(),
                                         update_date = lubridate::ymd())
            .Object@oecd_ticker <- character()
            .Object@url <- character()
            validObject(.Object)
            return(.Object)
          }
)


setMethod("oecd.ticker", "oecd",
          function(object
          ) {
            object@oecd_ticker <- macroparsing::oecd_names %>%
              .[which(.$ticker==object@ticker),] %>%
              mutate(oecd_ticker = paste0(index_name, '.', country_name)) %>%
              .$oecd_ticker

            validObject(object)
            return(object)
          }
)

setMethod("url", "oecd",
          function(object
          ) {
            object@url <- paste0('https://stats.oecd.org/sdmx-json/data/MEI_CLI/',
                                 object@oecd_ticker,
                                 '.M/OECD?startTime=',
                                 substr(object@observation_start, 1, 7),
                                 '&detail=DataOnly')

            validObject(object)
            return(object)
          }
)

setMethod("download.ts", "oecd",
          function(object
          ) {
            object@ts <- jsonlite::fromJSON(object@url,
                            flatten=TRUE)[['dataSets']] %>%
            sapply(X = ., FUN = function(x) x[[1]][1]) %>%
              .[-c(1)] %>%
              as.numeric() %>%
              tibble::as_tibble() %>%
              tibble::add_column(date = seq.Date(from = object@observation_start,
                                         by = '1 month',
                                         length.out = nrow(.)),
                         .before = 1) %>%
              dplyr::mutate(update_date = as.Date(Sys.Date()))

            validObject(object)
            return(object)
          }
)
