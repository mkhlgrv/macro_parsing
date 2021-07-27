#' @include common.R




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


