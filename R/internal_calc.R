#' @include common.R
#' @include classes.R

setMethod(
  "related.ticker", "internal",
  function(object) {
    object@related_ticker <- rmedb::internal_tickers %>%
      .[which(.$ticker == object@ticker), ] %>%
      .$related_ticker
    validObject(object)
    return(object)
  }
)


setMethod(
  "download.ts", "internal",
  function(object) {
    if(object@ticker=='construction_real'){
      file_name_numenator <- paste0(Sys.getenv('directory'), "/data/raw/", 'construction_nom', ".csv")
      file_name_denominator <- paste0(Sys.getenv('directory'), "/data/raw/", 'ppi_construction', ".csv")
      numenator <- data.table::fread(file_name_numenator, colClasses = c("Date", "numeric", "Date")) %>%
        dplyr::group_by(date) %>%
        dplyr::filter(update_date == max(update_date)) %>%
        dplyr::ungroup()
      denominator <- data.table::fread(file_name_denominator, colClasses = c("Date", "numeric", "Date"))%>%
        dplyr::group_by(date) %>%
        dplyr::filter(update_date == max(update_date)) %>%
        dplyr::ungroup()
      object@ts <- numenator
      object@ts$value <- (numenator$value/cumprod(denominator$value/100))/
        (numenator$value/cumprod(denominator$value/100))[1]*100

    } else{
      file_name <- paste0(Sys.getenv('directory'), "/data/raw/", object@related_ticker, ".csv")
      object@ts <- data.table::fread(file_name, colClasses = c("Date", "numeric", "Date"))
    }


    validObject(object)
    return(object)
  }
)
