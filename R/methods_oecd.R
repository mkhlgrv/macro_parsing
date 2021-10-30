#' @include common.R



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
