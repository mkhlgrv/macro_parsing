
update.log.file <- function(){
  list.files(path = paste0(Sys.getenv("directory"), "/data/raw")) %>%
    purrr::map_dfr(function(filei){
      ticker <- gsub(pattern = ".csv", replacement = "", x = filei)
      log_info <- data.table::fread(paste0(Sys.getenv("directory"), "/data/raw/",filei)) %>%
        dplyr::group_by(update_date) %>%
        dplyr::summarise(n = dplyr::n()) %>%
        dplyr::mutate(ticker = ticker,
                      update_date = as.Date(update_date))
    }) %>%
    data.table::fwrite(file = paste0(Sys.getenv("directory"), "/data/info.csv"))
}

log.by.ticker <- function(object){
  downloaded_rows <- nrow(object@ts_new)
  downloaded <- ""
  if(downloaded_rows>0){
    downloaded <- paste(" downloaded:",downloaded_rows)
  }
  transformed_rows <- nrow(object@ts_tf)
  transformed <- ""
  if(transformed_rows>0){
    transformed <- paste(" transformed:",transformed_rows)
  }
  paste0(Sys.time(),
         " ",object@ticker,
         ": success!",
         downloaded, transformed)
}

log.by.table <- function(object){
  if(is.na(object@modified)|object@modified != object@source_modified){
    flag <- paste("version of", object@source_modified, "downloaded")
  }
  else{
    flag <- "is up-to-date"
  }
  paste0(Sys.time(),
         " ",object@table,
         ": ",flag)

}
