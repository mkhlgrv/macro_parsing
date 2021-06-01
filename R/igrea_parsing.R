get.kilian.data <- function(){
  
}

setClass('igrea',slots = list(url='character'),
         contains = 'parsed_ts')

setMethod("initialize", "igrea",
          function(.Object,
                   ticker,
                   observation_start,
                   date_from,
                   ts,
                   url
          ) {             
            .Object@ticker <- character()
            .Object@observation_start <- lubridate::ymd()
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




setMethod("url", "igrea",
          function(object
          ) {
            object@url <- 'https://www.dallasfed.org/-/media/Documents/research/igrea/igrea.xlsx'
            
            validObject(object)
            return(object)
          }
)

setMethod("download.ts", "igrea",
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

