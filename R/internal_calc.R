#' @include common.R
#' @include classes.R

setMethod(
  "related.ticker", "internal",
  function(object) {
    object@related_ticker <- macroparsing::internal_tickers %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$related_ticker
    validObject(object)
    return(object)
  }
)


setMethod(
  "download.ts", "internal",
  function(object) {
    file_name <- paste0(Sys.getenv('directory'), "/data/raw/", object@related_ticker, ".csv")
    object@ts <- data.table::fread(file_name, colClasses = c("Date", "numeric", "Date"))

    validObject(object)
    return(object)
  }
)
