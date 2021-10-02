setClass("parsed_ts",
         slots = list(
           ticker = "character",
           observation_start = "Date",
           use_archive = 'logical',
           previous_date_till = "Date",
           date_from = "Date",
           ts = "data.frame",
           url = 'character',
           freq = 'factor',
           transform = 'character',
           deseason = 'character',
           transform.ts = "data.frame",
           deseason.ts = "data.frame"
         )
)


setMethod(
  "initialize", "parsed_ts",
  function(.Object) {
    .Object@observation_start <- lubridate::ymd()
    .Object@previous_date_till <- lubridate::ymd()
    .Object@date_from <- lubridate::ymd()
    .Object@ts <- tibble::tibble(
      date = lubridate::ymd(),
      value = numeric(),
      update_date = lubridate::ymd()
    )
    .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
    validObject(.Object)
    return(.Object)
  }
)

setClass('cbr',
         slots = list(
           cbr_ticker = 'character'
         ),
         contains = 'parsed_ts')


setMethod("initialize", "cbr",
          function(.Object

          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))

            validObject(.Object)
            return(.Object)
          }
)


setClass('dallasfed',
         contains = 'parsed_ts')
setMethod("initialize", "dallasfed",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)
setClass('fred',
         contains = 'parsed_ts')

setMethod("initialize", "fred",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)

setClass('moex',slots = list(date_till = 'Date'),
         contains = 'parsed_ts')

setMethod("initialize", "moex",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            .Object@date_till <- lubridate::ymd()
            validObject(.Object)
            return(.Object)
          }
)



setClass('oecd',
         slots = list(oecd_ticker = 'character'),
         contains = 'parsed_ts')


setMethod("initialize", "oecd",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)

setClass('rosstat',
         slots = list(table = 'character',
                      file_path = 'character',
                      sheet_info = 'data.frame'),
         contains = 'parsed_ts')


setMethod("initialize", "rosstat",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
            validObject(.Object)
            return(.Object)
          }
)


setClass('internal',
         slots = list(related_ticker = 'character'),
         contains = 'parsed_ts')


setMethod("initialize", "internal",
          function(.Object
          ) {
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(
              date = lubridate::ymd(),
              value = numeric(),
              update_date = lubridate::ymd()
            )
            .Object@freq <- factor(levels = c('d', 'w', 'm', 'q'))
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
                      modified = "character")
)

setMethod("initialize","rosstat_table",
          function(.Object, table){
            .Object@table <-  table
            .Object@url <- macroparsing::rosstat_tables %>%
              .[which(.$table == .Object@table), ] %>%
              .$url
            .Object@ext <- macroparsing::rosstat_tables %>%
              .[which(.$table == .Object@table), ] %>%
              .$ext

            .Object@pattern <- macroparsing::rosstat_table_patterns %>%
              .[which(.$table == .Object@table), ] %>%
              .[order(.$order)] %>%
              .$pattern %>%
              as.list()

            .Object@pattern[length(.Object@pattern)] <- 'href=\\"(.*?)\\"'
            .Object@modified <- ""




            validObject(.Object)
            return(.Object)
          })
