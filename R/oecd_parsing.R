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
            object@oecd_ticker <- data.table::fread('data/info/oecd_name_list.csv',
                                             select = c('ticker',
                                                        'index_name',
                                                        'country_name')) %>%
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


download.oecd <- function(x){
  name <- x$name
  cname <- name
  if(cname=='G-7'){
    cname <- 'G7'
  }
  index <- x$index


  url <- get.url.oecd(index = index, country_name = name)

  res <- fromJSON(url,flatten=TRUE)[['dataSets']]
  sapply(res, function(x) x[[1]][1])[-c(1)] %>% as.numeric %>%
    as_tibble() %>%
    set_colnames(paste0(index,'_',cname)) %>%
    add_column(date = seq.Date(from = as.Date('2006-01-01'),
                               by = '1 month',
                               length.out = nrow(.)),
               .before = 1)
}
get.oecd.data <- function(){


  res <- expand.grid(name = c('OECDE', 'OECD', 'G-7', 'EA19','USA','CHN', 'RUS'),
                     index = c('cli', 'bci', 'cgi'), stringsAsFactors = FALSE) %>%
    split(1:nrow(.)) %>%
    map(download.oecd)
  res %<>% plyr::join_all(type='full', by='date') %>%
    arrange(date)
  export(res,
         'raw/oecd monthly.xlsx')

}
