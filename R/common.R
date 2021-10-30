#'@include classes.R

date.from <- function(object) {
  UseMethod("date.from")
}
date.till <- function(object) {
  UseMethod("date.till")
}

url <- function(object) {
  UseMethod("url")
}

download.ts.chunk <- function(object) {
  UseMethod("download.ts.chunk")
}
download.ts <- function(object) {
  UseMethod("download.ts")
}

write.ts <- function(object) {
  UseMethod("write.ts")
}


transform.ts <- function(object) {
  UseMethod("transform.ts")
}
write.ts.tf <- function(object) {
  UseMethod("write.ts.tf")
}

setMethod(
  "write.ts", "parsed_ts",
  function(object) {
    object@ts_new <-  object@ts
    if(object@use_archive&object@observation_start==object@date_from){
      object@ts_new <- data.table::rbindlist(list(
        rmedb:::archive[[object@ticker]],
        object@ts_new
      )) %>%
        dplyr::arrange(
          date, update_date
        ) %>%
        data.table::as.data.table()
    }
    file_name <- paste0(Sys.getenv('directory'), '/data/raw/',object@ticker,".csv")

    object@ts_old

    object@ts_new$value <- round(object@ts_new$value, 5)
    if(nrow(object@ts_old)!=0){
      object@ts_new <- dplyr::anti_join(object@ts_new,
                                        object@ts_old,
                                    by =c('date', 'value')
      )
    }


    data.table::fwrite(object@ts_new,
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


setMethod("transform.ts", "parsed_ts",
          function(object
          ) {

            object@ts_tf <- data.table::fread(file = paste0(Sys.getenv('directory'),
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

                } else if(object@transform=='base'){
                  dplyr::mutate(.data = .,value = cumprod(value/100)/value[1]*100)
                } else { .}
              } %>%
              dplyr::mutate(.data = .,value = round(value, 5))
            validObject(object)
            return(object)
          }
)



setMethod("write.ts.tf", "parsed_ts",
          function(object) {

            data.table::fwrite(object@ts_tf,
                               file = paste0(Sys.getenv('directory'), '/data/tf/',
                                             object@ticker,
                                             ".csv"),
                               append = FALSE)
            validObject(object)
            return(object)
          }
)


