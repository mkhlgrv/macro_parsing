#'@include classes.R
ticker <- function(object, ticker) {
  UseMethod("ticker")
}
observation.start <- function(object) {
  UseMethod("observation.start")
}
date.from <- function(object) {
  UseMethod("date.from")
}
previous.date.till <- function(object) {
  UseMethod("previous.date.till")
}
date.till <- function(object) {
  UseMethod("date.till")
}

url <- function(object) {
  UseMethod("url")
}

cbr.ticker <- function(object) {
  UseMethod("cbr.ticker")
}


download.ts.chunk <- function(object) {
  UseMethod("download.ts.chunk")
}
download.ts <- function(object) {
  UseMethod("download.ts")
}
use.archive <- function(object) {
  UseMethod("use.archive")
}

write.ts <- function(object) {
  UseMethod("write.ts")
}

freq <- function(object) {
  UseMethod("freq")
}
oecd.ticker <- function(object) {
  UseMethod("oecd_ticker")
}

transform <- function(object) {
  UseMethod("transform")
}

transform.ts <- function(object) {
  UseMethod("transform.ts")
}
write.transform.ts <- function(object) {
  UseMethod("write.transform.ts")
}

deseason <- function(object) {
  UseMethod("deseason")
}
deseason.ts <- function(object) {
  UseMethod("deseason.ts")
}
write.deseason.ts <- function(object) {
  UseMethod("write.deseason.ts")
}
pattern <- function(object) {
  UseMethod("pattern")
}



setMethod(
  "ticker", "parsed_ts",
  function(object, ticker) {
    object@ticker <- ticker
    validObject(object)
    return(object)
  }
)


setMethod(
  "observation.start", "parsed_ts",
  function(object) {
    object@observation_start <- macroparsing::variables %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$observation_start %>%
      lubridate::ymd()
    validObject(object)
    return(object)
  }
)

setMethod(
  "use.archive", "parsed_ts",
  function(object) {
    object@use_archive <- macroparsing::variables %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$use_archive
    validObject(object)
    return(object)
  }
)

setMethod(
  "transform", "parsed_ts",
  function(object) {
    object@transform <- macroparsing::variables %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$transform
    validObject(object)
    return(object)
  }
)


setMethod(
  "deseason", "parsed_ts",
  function(object) {
    object@deseason <- macroparsing::variables %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$deseason
    validObject(object)
    return(object)
  }
)
setMethod(
  "previous.date.till", "parsed_ts",
  function(object) {
    object@previous_date_till <-
      data.table::fread(paste0(Sys.getenv('directory'),
                                           "/data/raw/",
                                           object@ticker,
                                           ".csv"),
      select = "date"
    ) %>%
      .$date %>%
      .[length(.)] %>%
      lubridate::ymd()

    validObject(object)
    return(object)
  }
)

setMethod(
  "write.ts", "parsed_ts",
  function(object) {
    if(object@use_archive&object@observation_start==object@date_from){
      object@ts <- data.table::rbindlist(list(
        eval(parse(text = paste0('macroparsing:::archive_',object@ticker))),
        object@ts
      )) %>%
        dplyr::arrange(
          date, update_date
        )
    }

    file_name <- paste0(Sys.getenv('directory'), '/data/raw/',object@ticker,
                        ".csv")
    ts_old <- data.table::fread(file= file_name, encoding = "UTF-8",
                                colClasses = c("Date", "numeric", "Date"))

    object@ts <- dplyr::anti_join(object@ts,
                                  ts_old,
                     by =c('date', 'value')
                     )

    data.table::fwrite(object@ts,
                       file = file_name,
                       append = TRUE)
    validObject(object)
    return(object)
  }
)

setMethod("date.from", "parsed_ts",
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


setMethod("freq", "parsed_ts",
          function(object
          ) {
            object@freq <- macroparsing::variables %>%
              .[which(.$ticker==object@ticker),] %>%
              .$freq %>%
              factor(levels = c('d', 'w', 'm', 'q'))
            validObject(object)
            return(object)
          }
)

setMethod("transform.ts", "parsed_ts",
          function(object
          ) {

            object@transform.ts <- data.table::fread(file = paste0(Sys.getenv('directory'),
                                                                   '/data/raw/',
                                                                   object@ticker,
                                                                   '.csv')) %>%
              na.omit() %>%
              dplyr::group_by(date) %>%
              dplyr::filter(dplyr::row_number() == max(dplyr::row_number())) %>%
              dplyr::ungroup() %>%
              {
                if(object@transform=='cummean'){
                  dplyr::group_by(.data = .,
                                  zoo::as.yearmon(date)) %>%
                    dplyr::mutate(value = dplyr::cummean(value)) %>%
                    dplyr::ungroup() %>%
                    dplyr::select(date, value, update_date)

                } else{ .}
              }
            validObject(object)
            return(object)
          }
)


setMethod("deseason.ts", "parsed_ts",
          function(object
          ) {

            object@deseason.ts <- data.table::fread(file = paste0(Sys.getenv('directory'),
                                                                   '/data/transform/',
                                                                   object@ticker,
                                                                   '.csv'))
                deseason_fun <- function(value, value_lag){
                    if(object@deseason == "logdiff"){
                    log(value)-log(value_lag)
                    } else if(object@deseason == "diff"){
                    value - value_lag
                    } else if(object@deseason == "level"){
                    value
                    }
                }
                freq_fun <- {
                  if(object@freq%in% c('d', 'w', 'm')){
                    zoo::as.yearmon
                  } else if(object@freq== 'q'){
                    zoo::as.yearqtr
                  }
                }

                  lagged_ts <- dplyr::mutate(.data = object@deseason.ts,
                                             year_freq_lead = zoo::as.Date(freq_fun(date)+1)) %>%
                    dplyr::arrange(date) %>%
                    dplyr::group_by(year_freq_lead) %>%
                    dplyr::summarise(value_lag = dplyr::last(value))
                  object@deseason.ts <- object@deseason.ts %>%
                    dplyr::mutate(year_freq = zoo::as.Date(freq_fun(date))) %>%
                    dplyr::inner_join(lagged_ts, by = c("year_freq"="year_freq_lead")) %>%
                    dplyr::mutate(value = deseason_fun(value, value_lag)) %>%
                    dplyr::select(date, value, update_date)
            validObject(object)
            return(object)
          }
)

setMethod("write.transform.ts", "parsed_ts",
          function(object) {

            data.table::fwrite(object@transform.ts,
                               file = paste0(Sys.getenv('directory'), '/data/transform/',
                                             object@ticker,
                                             ".csv"),
                               append = FALSE)
            validObject(object)
            return(object)
          }
)



setMethod("write.deseason.ts", "parsed_ts",
          function(object) {

            data.table::fwrite(object@deseason.ts,
                               file = paste0(Sys.getenv('directory'), '/data/deseason/',
                                             object@ticker,
                                             ".csv"),
                               append = FALSE)
            validObject(object)
            return(object)
          }
)



