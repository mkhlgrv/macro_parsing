setClass("parsed_ts",
         slots = list(
           ticker = "character",
           observation_start = "Date",
           use_archive = 'logical',
           previous_date_till = "Date",
           date_from = "Date",
           ts = "data.frame",
           ts_new ="data.frame",
           ts_old="data.frame",
           freq = 'factor',
           transform = 'character',
           ts_tf = "data.frame"
         )
)


setMethod(
  "initialize", "parsed_ts",
  function(.Object, ticker_) {

    check.files.by.ticker(ticker_)

    .Object@ticker <- ticker_

    .Object@observation_start <- rmedb::variables %>%
      .[which(.$ticker == ticker_), ] %>%
      .$observation_start %>%
      lubridate::ymd()

    .Object@use_archive <- rmedb::variables %>%
      .[which(.$ticker == ticker_), ] %>%
      .$use_archive

    .Object@previous_date_till <-
      data.table::fread(paste0(Sys.getenv('directory'),
                               "/data/raw/",
                               ticker_,
                               ".csv"),
                        select = "date"
      ) %>%
      .$date %>%
      .[length(.)] %>%
      lubridate::ymd()



    ts_template <- tibble::tibble(
      date = lubridate::ymd(),
      value = numeric(),
      update_date = lubridate::ymd()
    )

    .Object@ts <- ts_template
    .Object@ts_new <- ts_template

    file_name <- paste0(Sys.getenv('directory'),
                        '/data/raw/',
                        ticker_,
                        ".csv")

    .Object@ts_old <-  data.table::fread(file= file_name,
                                         encoding = "UTF-8",
                                         colClasses = c("Date", "numeric", "Date"))

    .Object@ts_tf <- ts_template


    .Object@freq <- rmedb::variables %>%
      .[which(.$ticker==ticker_),] %>%
      .$freq %>%
      factor(levels = c('d', 'w', 'm', 'q'))

    .Object@transform <- rmedb::variables %>%
      .[which(.$ticker == ticker_), ] %>%
      .$transform



    # print(class(.Object))
    # print(date.from(.Object))
    .Object <- date.from(.Object)



    validObject(.Object)
    return(.Object)
  }
)

setClass("parsed_with_external_url_ts",
         slots = list(
  url = 'character'
),
contains = 'parsed_ts')

setMethod(
  "initialize", "parsed_with_external_url_ts",
  function(.Object, ticker_) {
    .Object <- callNextMethod()

    .Object <- url(.Object)
    validObject(.Object)
    return(.Object)
  }
)

setClass('cbr',
         slots = list(
           cbr_ticker = 'character'
         ),
         contains = 'parsed_with_external_url_ts')

setMethod(
  "initialize", "cbr",
  function(.Object, ticker_){

    .Object@cbr_ticker <-  rmedb::cbr_names %>%
      .[which(.$ticker==ticker_),] %>%
      .$cbr_ticker

    .Object <- callNextMethod()
    validObject(.Object)
    return(.Object)
  }
)

setClass('dallasfed',
         contains = 'parsed_with_external_url_ts')

setClass('fred',
         contains = 'parsed_ts')


setClass('moex',
         slots = list(date_till = 'Date'),
         contains = "parsed_with_external_url_ts")

setMethod(
  "initialize", "moex",
  function(.Object, ticker_){

    .Object@date_till <-  lubridate::ymd()

    .Object <- callNextMethod()
    validObject(.Object)
    return(.Object)
  }
)


setClass('oecd',
         slots = list(oecd_ticker = 'character'),
         contains = 'parsed_with_external_url_ts')

setMethod(
  "initialize", "oecd",
  function(.Object, ticker_){
    .Object <- callNextMethod()

    .Object@oecd_ticker <- rmedb::oecd_names %>%
      .[which(.$ticker==ticker_),] %>%
      dplyr::mutate(oecd_ticker = paste0(index_name, '.', country_name)) %>%
      .$oecd_ticker

    validObject(.Object)
    return(.Object)
  }
)


setClass('rosstat',
         slots = list(table = 'character',
                      file_path = 'character',
                      sheet_info = 'data.frame'),
         contains = 'parsed_ts')

setMethod(
  "initialize", "rosstat",
  function(.Object, ticker_){
    .Object <- callNextMethod()

    .Object@table <- rmedb::rosstat_ticker_tables %>%
      .[which(.$ticker == ticker_), ] %>%
      .$table

    lf <- list.files(paste0(Sys.getenv("directory"),
                            "/data/raw_excel/",
                            .Object@table),
                     full.names = TRUE)

    .Object@file_path <-  lf[length(lf)]

    .Object@sheet_info <-  rmedb::rosstat_headers %>%
      .[which(.$ticker  == ticker_), ]

    validObject(.Object)
    return(.Object)
  }
)
setClass('internal',
         slots = list(related_ticker = 'character'),
         contains = 'parsed_ts')



setMethod(
  "initialize", "internal",
  function(.Object, ticker_){
    .Object <- callNextMethod()

    .Object@related_ticker <- rmedb::internal_tickers %>%
      .[which(.$ticker == .Object@ticker), ] %>%
      .$related_ticker

    validObject(.Object)
    return(.Object)
  }
)

setClass("rosstat_table",
         slots = list(table = "character",
                      url = 'character',
                      ext = "character",
                      pattern = "list",
                      file_url = "character",
                      modified = "character",
                      source_modified = "character")
)
setMethod("initialize","rosstat_table",
          function(.Object, table){
            check.table(table)
            .Object@table <-  table

            .Object@url <- rmedb::rosstat_tables %>%
              .[which(.$table == .Object@table), ] %>%
              .$url
            .Object@ext <- rmedb::rosstat_tables %>%
              .[which(.$table == .Object@table), ] %>%
              .$ext

            .Object@pattern <- rmedb::rosstat_table_patterns %>%
              .[which(.$table == .Object@table), ] %>%
              .[order(.$order)] %>%
              .$pattern %>%
              as.list()

            .Object@pattern[length(.Object@pattern)] <- 'href=\\"(.*?)\\"'
            .Object@modified <- ""
            .Object@source_modified <- ""




            validObject(.Object)
            return(.Object)
          })
