#' @include common.R

find.url <- function(.Object){
  UseMethod("find.url")
}
download.from.url <- function(.Object){
  UseMethod("download.from.url")
}
modified <- function(.Object){
  UseMethod("last.modified")
}
source.modified <- function(.Object){
  UseMethod("source.modified")
}



setMethod("find.url","rosstat_table",
          function(.Object){
            .Object@file_url <- paste0("https://rosstat.gov.ru/",
                                       find.by.pattern(x = paste0(readLines(.Object@url,encoding = 'UTF-8'),
                                                                  collapse = ''),
                                                       pattern = .Object@pattern)
            )
            validObject(.Object)
            return(.Object)
          })

setMethod("modified","rosstat_table",
          function(.Object){
            lf <- list.files(paste0(Sys.getenv("directory"), "/data/raw_excel/", .Object@table), full.names = TRUE)
            if(length(lf)>0){
              last_file <- lf[length(lf)]
              .Object@modified <- stringr::str_match(string = last_file,
                                                     pattern = '\\d{4}-\\d{2}-\\d{2}')[1,1]
            }
            validObject(.Object)
            return(.Object)
          })

setMethod("source.modified","rosstat_table",
          function(.Object){
            try({
              pattern_name <- rmedb::rosstat_xls_patterns[which(
                rmedb::rosstat_xls_patterns$table==.Object@table
              )] %>%
                .$pattern

              string = readLines(.Object@url,
                                 encoding = 'UTF-8')

              x <- stringr::str_match(string = string, pattern = pattern_name)
              n <- which(!is.na(x))[1]


              string <- string[n:(n+100)]
              pattern_date = '\\d{2}\\.\\d{2}\\.\\d{4}'

              .Object@source_modified <- stringr::str_match(string = string, pattern = pattern_date) %>%
                na.omit %>%
                .[1,1]


              .Object@source_modified <- as.character(as.Date(.Object@source_modified, format = '%d.%m.%Y'))

            })


            validObject(.Object)
            return(.Object)
          })

setMethod("download.from.url","rosstat_table",
          function(.Object){


            temp_file <-
              tempfile(fileext = .Object@ext)



            download.file(.Object@file_url,
                          temp_file,
                          mode="wb",
                          quiet = TRUE)


            if(is.na(.Object@modified)|.Object@modified != .Object@source_modified){



              file_name <- paste0(Sys.getenv("directory"),
                                  "/data/raw_excel/",
                                  .Object@table,"/",
                                  .Object@source_modified,
                                  .Object@ext)

              file.copy(temp_file, file_name)
              file.remove(temp_file)
              gc()
            }

            validObject(.Object)
            return(.Object)
          }
)

