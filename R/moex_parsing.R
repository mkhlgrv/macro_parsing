#' @include common.R



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
                                select = c('end' = 'POSIXct', 'close'='numeric'),
                                verbose = FALSE) %>%
                dplyr::rename(date = end,
                       value = close) %>%
                dplyr::group_by(date) %>%
                dplyr::summarise(value = value[1]) %>%
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



