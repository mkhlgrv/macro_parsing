#' @include common.R
setClass('moex',
         slots = list(previous_date_till='Date',
                      date_till = 'Date',
                      url = 'character'
                      ),
         contains = 'parsed_ts')



setMethod("initialize", "moex",
          function(.Object,
                   ticker,
                   observation_start,
                   previous_date_till,
                   date_from,
                   date_till,
                   url,
                   ts
          ) {
            .Object@ticker <- character()
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@date_till <- lubridate::ymd()
            .Object@url <- character()
            .Object@ts <- tibble::tibble(date = lubridate::ymd(),
                                         value = numeric(),
                                         update_date = lubridate::ymd())
            validObject(.Object)
            return(.Object)
          }
)







setMethod("date.from", "moex",
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



setMethod("date.till", "moex",
          function(object
          ) {

              date_till <-  lubridate::today()
              if(difftime(date_till,
                          object@date_from,
                          units = 'days') > 100){
                date_till <- object@date_from+100
              }
              object@date_till <- date_till
            validObject(object)
            return(object)
          }
)

setMethod("url", "moex",
          function(object
          ) {
            object@url <- paste0('https://iss.moex.com/iss/engines/stock/markets/index/securities/',
                   object@ticker,
                   '/candles.csv?iss.only=history&interval=24&iss.reverse=true&from=',
                   format(object@date_from),
                   '&till=',
                   format(object@date_till),
                   '&iss.dp=point&iss.delimiter=,')

            validObject(object)
            return(object)
          }
)




setMethod("download.ts.chunk", "moex",
          function(object
          ) {
              object@ts <- data.table::fread(object@url,
                                select = c('end' = 'POSIXct', 'close'='numeric')) %>%
                dplyr::rename(date = end,
                       value = close) %>%
                dplyr::group_by(date) %>%
                dplyr::summarise(value = first(value)) %>%
                dplyr::ungroup() %>%
                dplyr::mutate(date = as.Date(date),
                       update_date = as.Date(Sys.Date())) %>%
                dplyr::bind_rows(object@ts) %>%
                dplyr::arrange(date, update_date)


              validObject(object)
              return(object)
            }

)


setMethod("download.ts", "moex",
          function(object
          ) {
            date_from <- object@date_from
            if(date_from < lubridate::today()){

              object <- object %>%
                date.till %>%
                url %>%
                download.ts.chunk %>%

                date.from
              if(object@date_from != date_from){

                object <- object %>%
                  download.ts
              }

            }
            validObject(object)
            return(object)




          }

)



