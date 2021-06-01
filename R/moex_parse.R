
setClass('moex',
         slots = list(ticker = 'character',
                      observation_start = 'Date',
                      previous_date_till='Date',
                      date_from = 'Date',
                      date_till = 'Date',
                      url = 'character',
                      ts = 'data.frame'
                      ))

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

setMethod("ticker", "moex",
          function(object, ticker
          ) {
            object@ticker <- ticker
            validObject(object)
            return(object)
          }
)


setMethod("observation.start", "moex",
          function(object
          ) {
            object@observation_start <- data.table::fread('data/info/var_list.csv',
                                              select = c('ticker', 'observation_start')) %>%
              .[which(.$ticker==object@ticker),] %>%
              .$observation_start %>% 
              lubridate::ymd()
            validObject(object)
            return(object)
          }
)



setMethod("previous.date.till", "moex",
          function(object) {
            object@previous_date_till <- data.table::fread(paste0('data/raw/',object@ticker,'.csv'),
                                               select = 'date') %>%
              .[nrow(.),] %>%
              .$date %>%
              lubridate::ymd()
              
            validObject(object)
            return(object)
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
              if(lubridate::difftime(date_till,
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
                dplyr::ungroup %>%
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
              object %<>% 
                date.till %>%
                url %>%
                download.ts.chunk %>%
                  
                date.from
              if(object@date_from != date_from){
                object %<>%
                  download.ts
              }
                
            }
            validObject(object)
            return(object)
            
            
            
            
          }
          
)






setMethod("write.ts", "moex",
          function(object
          ) {
            data.table::fwrite(parsed@ts,file = paste0('data/raw/',object@ticker,'.csv'),append=TRUE)
            validObject(object)
            return(object)
          }
)




