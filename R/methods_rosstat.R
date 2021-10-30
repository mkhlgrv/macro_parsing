#' @include utils.R


setMethod("download.ts","rosstat",
          function(object){

              freq_cols <- switch(object@sheet_info$freq,
                                  "q" = rep("guess",6),
                                  "m" = rep("guess",18),
                                  "m_cumul" = rep("guess",13),
                                  "m_numeric" = rep("guess",15),
                                  "q_horizontal" = rep("guess",500))

              first_period_name <- switch(object@sheet_info$freq,
                                          "q" = "I",
                                          "m" = "Jan",
                                          "m_cumul" = "Year",
                                          "m_numeric" = "^1$",
                                          "q_horizontal" = "I квартал")

              last_period_name <- switch(object@sheet_info$freq,
                                          "q" = "IV",
                                          "m" = "Dec",
                                          "m_cumul" = "Nov",
                                         "m_numeric" = "^12$",
                                         "q_horizontal" = NA)

              freq_by <- switch(object@sheet_info$freq,
                                "q" = "1 quarter",
                                "m" = "1 month",
                                "m_cumul" = "1 month",
                                "m_numeric" = "1 month",
                                "q_horizontal" = "1 quarter")


              sheet <- grep(paste0("(^",object@sheet_info$sheet,")( |\\.$|\\. |$)"),
                            readxl::excel_sheets(object@file_path))

              suppressMessages(
                res <- readxl::read_excel(path = object@file_path,
                                          sheet = sheet,
                                          skip =  object@sheet_info$start_row-1)
              )



              start_row <- grep(pattern = object@sheet_info$header_pattern,
                                x = res[,object@sheet_info$header_column]%>%
                                  dplyr::pull(1)
                                )[object@sheet_info$n_match]+
                object@sheet_info$skip_after_header

              if(object@sheet_info$freq != "q_horizontal"){
                res <-  res[start_row:nrow(res),]


                if(object@sheet_info$end_row_indicator == 'empty_row'){
                  non_year_rows <- which(grepl("^\\d{4}",res[,object@sheet_info$header_column] %>%
                           dplyr::pull(1))==FALSE)
                  if(length(non_year_rows)==0){
                    end_row <- nrow(res)
                  } else{
                    end_row <- non_year_rows[1]-1
                  }



                } else if(object@sheet_info$end_row_indicator == 'next_serie'){
                  end_row <- grep(object@sheet_info$header_pattern,
                                  res[,object@sheet_info$header_column]%>%
                                    dplyr::pull(1))[2] - 1
                }


                start_year <- res[1,object@sheet_info$header_column] %>%
                  dplyr::pull(1) %>%
                  substr(start = 1,stop = 4) %>%
                  as.numeric()

                start_column <- grep(first_period_name, colnames(res))[1]
                end_column <- grep(last_period_name, colnames(res))[1]

                if(object@sheet_info$freq=='m_cumul'){
                  columns <- c((start_column+1):end_column,
                               start_column)
                } else {
                  columns <- start_column:end_column
                }


                suppressWarnings({
                  value <-  res[1:end_row,
                                columns] %>%
                    as.data.frame() %>%
                    t %>%
                    as.matrix %>%
                    check.bracket() %>%
                    as.numeric()
                })


              } else{



                suppressMessages(
                  year_colnames <- readxl::read_excel(path = object@file_path,
                                                      sheet = sheet,
                                                      skip =  object@sheet_info$start_row-2, )%>%
                    colnames()
                )


                start_year <- stringr::str_match(year_colnames, '\\d{4}') %>%
                  na.omit %>%
                  .[1,1] %>%
                  as.numeric()


                res <-  res[start_row,
                            (object@sheet_info$header_column+1):ncol(res)] %>%
                  as.data.frame()
                value <- res %>%
                  as.numeric()
              }
              gc()

              object@ts <- tibble::tibble(
                date = seq.Date(as.Date(paste0(start_year, "-01-01")), by =freq_by, length.out = length(value) ),
                value = value
              ) %>%
                dplyr::mutate(update_date = as.Date(Sys.Date())) %>%
                na.omit() %>%
                dplyr::arrange(date, update_date) %>%
                data.table::as.data.table()


            validObject(object)
            return(object)
          })
