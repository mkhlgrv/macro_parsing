#' @include common.R
setClass('dallasfed',slots = list(url='character'),
         contains = 'parsed_ts')

setMethod("initialize", "dallasfed",
          function(.Object,
                   ticker,
                   observation_start,
                   date_from,
                   ts,
                   url
          ) {
            .Object@ticker <- character()
            .Object@observation_start <- lubridate::ymd()
            .Object@use_archive <- logical()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(date = lubridate::ymd(),
                                         value = numeric(),
                                         update_date = lubridate::ymd())
            .Object@url <- character()
            validObject(.Object)
            return(.Object)
          }
)




setMethod("url", "dallasfed",
          function(object
          ) {
            object@url <- 'https://www.dallasfed.org/-/media/Documents/research/igrea/igrea.xlsx'

            validObject(object)
            return(object)
          }
)

setMethod("download.ts", "dallasfed",
          function(object
          ) {
            try({

                httr::GET(object@url,
                          httr::write_disk(temp_file <-
                                             tempfile(fileext = ".xlsx")))
              object@ts <- readxl::read_xlsx(temp_file,
                                sheet = 1,
                                skip = 1,
                                col_names = c('date', 'value'),
                                col_types = c('date', 'numeric')) %>%
                dplyr::mutate(date = lubridate::ymd(date),
                              update_date = as.Date(Sys.Date())) %>%
                dplyr::arrange(date, update_date)
            }, silent = TRUE)
            validObject(object)
            return(object)

          }
)



setMethod(
  "write.ts", "dallasfed",
  function(object) {

    data.table::fwrite(object@ts,
                       file = paste0(Sys.getenv('directory'), '/data/raw/',object@ticker,
                                     ".csv"),
                       append = TRUE)
    validObject(object)
    return(object)
  }
)

