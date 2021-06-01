library(lubridate)
library(dplyr)
library(data.table)
library(magrittr)
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
            .Object@observation_start <- ymd()
            .Object@previous_date_till <- ymd()
            .Object@date_from <- ymd()
            .Object@date_till <- ymd()
            .Object@url <- character()
            .Object@ts <- tibble(date = ymd(),
                                 value = numeric(), 
                                 update_date = ymd())
            validObject(.Object)
            return(.Object)
          }
)
observation.start <- function(object){
  object@observation_start
}
setMethod("observation.start", "moex",
          function(object
          ) {
            object@observation_start <- fread('data/info/var_list.csv',
                                              select = c('ticker', 'observation_start')) %>%
              .[which(.$ticker==object@ticker),] %>%
              .$observation_start %>% 
              ymd
            validObject(object)
            return(object)
          }
)

ticker <- function(object, ticker){
  object@ticker
}
setMethod("ticker", "moex",
          function(object, ticker
          ) {
            object@ticker <- ticker
            validObject(object)
            return(object)
          }
)
date.from <- function(object){
  object@date_from
}

previous.date.till <- function(object){
  object@previous_date_till
}
setMethod("previous.date.till", "moex",
          function(object) {
            object@previous_date_till <- fread(paste0('data/raw/',object@ticker,'.csv'),
                                               select = 'date') %>%
              .[nrow(.),] %>%
              .$date %>%
              ymd
              
            validObject(object)
            return(object)
          }
)
date.from <- function(object){
  object@date_from
}

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
              object@date_from <- object@observation_start %>% ymd
            } else {
              object@date_from <- date_from %>% ymd
            }
            validObject(object)
            return(object)
          }
)

date.till <- function(object){
  object@date_till
}

setMethod("date.till", "moex",
          function(object
          ) {
            
              date_till <-  today()
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

url <- function(object){
    object@url
  }

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


download.ts.chunk <- function(object){
  object@ts
}

setMethod("download.ts.chunk", "moex",
          function(object
          ) {
              object@ts <- fread(object@url,
                                select = c('end' = 'POSIXct', 'close'='numeric')) %>%
                rename(date = end,
                       value = close) %>%
                group_by(date) %>%
                summarise(value = first(value)) %>%
                ungroup %>%
                mutate(date = as.Date(date),
                       update_date = as.Date(Sys.Date())) %>%
                bind_rows(object@ts) %>%
                arrange(date, update_date)
              
              
              validObject(object)
              return(object)
            }
            
)

download.ts <- function(object){
  object@ts
}

setMethod("download.ts", "moex",
          function(object
          ) {
            date_from <- object@date_from
            if(date_from < today()){
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





write.ts <- function(object){
  object@ts
}

setMethod("write.ts", "moex",
          function(object
          ) {
            fwrite(parsed@ts,file = paste0('data/raw/',object@ticker,'.csv'),append=TRUE)
            validObject(object)
            return(object)
          }
)




