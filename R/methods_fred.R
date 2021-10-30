#' @include common.R

setMethod("date.from", "fred",
          function(object
          ) {


            if(length(object@previous_date_till)==0){
              object@date_from <- object@observation_start %>%
                lubridate::ymd()
            } else {
              date_from <- object@previous_date_till %>%
                lubridate::ymd()
              if(object@freq == 'm'){
                object@date_from <- zoo::as.yearmon(date_from+31) %>%
                  zoo::as.Date() %>%
                  lubridate::ymd()
              } else{
                object@date_from <- lubridate::ymd(date_from+1)
              }
            }

            validObject(object)
            return(object)
          }
)


setMethod("download.ts", "fred",
          function(object
          ) {
            fredr::fredr_set_key(Sys.getenv('fredr_api_key'))

            object@ts <- fredr::fredr(object@ticker,
            frequency = object@freq %>% as.character,
            observation_start = object@date_from) %>%
              dplyr::select(date, value) %>%
              dplyr::mutate(date = as.Date(date),
                     update_date = as.Date(Sys.Date())) %>%
              dplyr::arrange(date, update_date)

            validObject(object)
            return(object)
          }
)




