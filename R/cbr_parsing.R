#' @include common.R
setClass('cbr',
         slots = list(
                      url = 'character',
                      freq = 'factor',
                      cbr_ticker = 'character'
         ),
         contains = 'parsed_ts')



#' Title
#'
#' @param cbr
#'
#' @return
#' @export
#'
#' @examples
setMethod("initialize", "cbr",
          function(.Object,
                   ticker,
                   observation_start,
                   previous_date_till,
                   date_from,
                   ts,
                   url,
                   freq,
                   cbr_ticker

          ) {
            .Object@ticker <- character()
            .Object@observation_start <- lubridate::ymd()
            .Object@previous_date_till <- lubridate::ymd()
            .Object@use_archive <- logical()
            .Object@date_from <- lubridate::ymd()
            .Object@ts <- tibble::tibble(date = lubridate::ymd(),
                                         value = numeric(),
                                         update_date = lubridate::ymd())
            .Object@url <- character()
            .Object@freq <- factor(levels = c('d', 'w', 'm'))
            .Object@cbr_ticker <- character()
            validObject(.Object)
            return(.Object)
          }
)



setMethod("freq", "cbr",
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


setMethod("date.from", "cbr",
          function(object
          ) {
            if(length(object@previous_date_till)==0){
              object@date_from <- object@observation_start
            } else{
              date_from <- object@previous_date_till
              if(object@freq=='d'){
                object@date_from <- date_from
              } else if(object@freq == 'w'){
                object@date_from <- date_from+7
              } else if(object@freq == 'm'){
                object@date_from <- zoo::as.yearmon(date_from+31) %>%
                  zoo::as.Date() %>%
                  lubridate::ymd()
              } else if(object@freq == 'q'){
                object@date_from <- zoo::as.yearqtr(date_from+92) %>%
                  zoo::as.Date() %>%
                  lubridate::ymd()
              }
            }

            validObject(object)
            return(object)
          }
)

setMethod("cbr.ticker", "cbr",
          function(object
          ) {
            object@cbr_ticker <- macroparsing::cbr_names %>%
              .[which(.$ticker==object@ticker),] %>%
              .$cbr_ticker
            validObject(object)
            return(object)
          }
)



setMethod("url", "cbr",
          function(object
          ) {
            # через XML:
            # usd XML_dynamic.asp?
            # остаток средств на корр счетах XML_ostat.asp?
            # ставки межбанковского рынка xml_mkr.asp?
            # ставок привлечения средств по депозитным операциям Банка России на денежном рынке xml_depo.asp?
            # динамики ставок «валютный своп» — " Валютный своп buy/sell overnight " xml_swap.asp?
            # usd ----
            if(object@ticker %in% c('usd')){ # aslo: other currency
              # currency codes: http://www.cbr.ru/scripts/XML_val.asp?d=0
              object@url <- paste0('http://www.cbr.ru/scripts/XML_dynamic.asp?date_req1=',
                     format(object@date_from, format = "%d/%m/%Y")
                     ,'&date_req2=',
                     format(lubridate::today(), format = "%d/%m/%Y")
                     ,'&VAL_NM_RQ=',
                     object@cbr_ticker)
            }
            else if(object@ticker %in% c('miacr')){ # also: depo, swap, ostat

              object@url <- paste0('http://www.cbr.ru/scripts/xml_',
                     object@cbr_ticker
                     ,'.asp?date_req1=',
                     format(object@date_from, format = "%d/%m/%Y")
                     ,'&date_req2=',
                     format(lubridate::today(), format = "%d/%m/%Y")
                     )
            }
            else if(object@ticker %in% c('mosprime',
                                    'saldo',
                                    'repo',
                                    'fer',
                                    'money_base_weekly',
                                    'money_base')){
              object@url <-
                paste0('https://www.cbr.ru/eng/hd_base/',
                       object@cbr_ticker,
                       '/')

              if(object@ticker %in% c('fer', 'money_base_weekly', 'money_base')){
                object@url <-
                  paste0(object@url,
                         '?UniDbQuery.Posted=True',
                         '&UniDbQuery.From=',
                         format(as.Date(object@date_from),
                                format = "%m/%Y"),
                         '&UniDbQuery.To=',
                         format(lubridate::today(),
                                format = "%m/%Y"))
              }
            }
            else if(object@ticker %in% c('m2', 'export_usd', 'import_usd')){
              object@url <- paste0('https://www.cbr.ru/vfs/eng/statistics/',
                                   object@cbr_ticker,
                                   '.xlsx')

            }



            validObject(object)
            return(object)
          }
)


rename.in.xml <- function(x, ticker){

  ticker <- match.arg(ticker, choices = c('usd', 'miacr'))
  value_name <- switch(ticker,
                       usd = 'Value',
                       miacr = 'C1')
  x %>% .[,c('.attrs', value_name)] %>%
    dplyr::rename(date = .attrs,
                  value = {{value_name}} )

}

format.date.value.xml <- function(x, ticker){
  if(ticker %in% c('usd')){
    x %>%
      .[grep(pattern = '\\d{2}(\\.)\\d{2}(\\.)\\d{4}',
           x = .$date),] %>%
      dplyr::mutate(value = gsub(",", "\\.", value) %>%
                      as.numeric()) %>%
      dplyr::mutate(date = as.Date(date, format = '%d.%m.%Y'))
  } else if(ticker %in% c('miacr')){
    x %>%
      .[grep(pattern = '\\d{2}(/)\\d{2}(/)\\d{4}',
             x = .$date),]  %>%
      dplyr::mutate(date = as.Date(date, format = '%d/%m/%Y'))
  } else if(ticker %in% c('mosprime',
                          'saldo',
                          'repo',
                          'fer')){
    x %>%
      dplyr::mutate(date = as.Date(date, format = '%d/%m/%Y')) %>%
      dplyr::mutate(value = gsub(",", "", value) %>%
                      gsub(pattern = "—",replacement =  NA,x = .) %>%
                      as.numeric())
  } else if(ticker %in% c('money_base_weekly',
                                'money_base')){
    x %>%
      dplyr::mutate(date = as.Date(date, format = '%d.%m.%Y')) %>%
      dplyr::mutate(value = gsub(",", "", value) %>%
                      as.numeric())
  }
}
setMethod("download.ts", "cbr",
          function(object
          ) {
            # через XML:
            # usd XML_dynamic.asp?
            # остаток средств на корр счетах XML_ostat.asp?
            # ставки межбанковского рынка xml_mkr.asp?
            # ставок привлечения средств по депозитным операциям Банка России на денежном рынке xml_depo.asp?
            # динамики ставок «валютный своп» — " Валютный своп buy/sell overnight " xml_swap.asp?
            # usd ----
            if(object@ticker %in% c('usd', 'miacr')){ # aslo: other currency, swap, depo, ostat
              object@ts <- purrr::map_dfr(XML::xmlToList(object@url ),
                      data.frame) %>%
                tibble::remove_rownames() %>%
                rename.in.xml(ticker = object@ticker) %>%
                format.date.value.xml(ticker = object@ticker) %>%
                dplyr::mutate(date = as.Date(date),
                              update_date = as.Date(Sys.Date())) %>%
                dplyr::arrange(date, update_date)

            }
            else if(object@ticker %in% c('mosprime',
                                           'saldo',
                                           'repo',
                                           'fer',
                                           'money_base_weekly',
                                           'money_base')){


              if(object@ticker %in% c('mosprime', 'saldo', 'repo')){


                x <- httr::POST(object@url,
                            body = list('UniDbQuery.From' =
                                          format(as.Date(object@date_from),
                                                 format = "%d/%m/%Y"),
                                        'UniDbQuery.To' =
                                          format(lubridate::today(),
                                                 format = "%d/%m/%Y"),
                                        'UniDbQuery.Posted'= 'True'))
              } else if(object@ticker %in% c('miacr', 'fer',
                                       'money_base_weekly',
                                       'money_base')){
                x <- httr::GET(object@url)
              }
              if(object@ticker == 'mosprime'){
                col_index <- c(1,5)
              } else{
                col_index <- c(1,2)
              }
              n_skip <- integer()
              if(object@ticker == 'money_base'){
                n_skip <- 1L
              }


              x <- XML::readHTMLTable(httr::content(x, "text"),
                                      skip.rows = n_skip)[[1]] %>%
                .[,col_index]
              colnames(x) <- c('date', 'value')


              object@ts <- x %>%
                format.date.value.xml(ticker = object@ticker) %>%
                dplyr::mutate(update_date = as.Date(Sys.Date())) %>%
                dplyr::arrange(date, update_date)


              }
          else if(object@ticker %in% c('m2', 'export_usd', 'import_usd')){
            httr::GET(object@url,
                      httr::write_disk(temp_file <-
                                         tempfile(fileext = ".xlsx")))
            if(object@ticker %in% 'm2'){

              object@ts <- readxl::read_xlsx(temp_file,
                                sheet = 1,
                                skip = 5,
                                range = 'A6:B10000',
                                col_names = c('date', 'value')) %>%
                dplyr::mutate(date = seq.Date(from = object@observation_start,
                                       by = as.character(object@freq),
                                       length.out = nrow(.))) %>%
                dplyr::mutate(update_date = as.Date(Sys.Date())) %>%
                dplyr::arrange(date, update_date)
            } else if(object@ticker %in% c('export_usd', 'import_usd')){
              n_col <- readxl::read_xlsx(temp_file,
                               sheet = 1,
                               skip = 12,
                               n_max = 0) %>%
                ncol()
              row_n <- switch(object@ticker,
                              'export_usd'=2,
                              'import_usd' = 3)
              object@ts <- readxl::read_xlsx(temp_file,
                                             sheet = 1,
                                             skip = 11,
                                             n_max = 3,
                                             col_types = c('skip',
                                                           rep(c(rep('numeric', 4),
                                                                 'skip'),
                                                               (n_col-1)/5+1)[1:(n_col-1)])) %>%
                .[row_n,] %>%
                as.numeric() %>%
                tibble::tibble(date = NA,'value' = .) %>%
                dplyr::mutate(date = seq.Date(from = object@observation_start,
                                              by = as.character(object@freq),
                                              length.out = nrow(.))) %>%
                dplyr::mutate(update_date = as.Date(Sys.Date())) %>%
                dplyr::arrange(date, update_date)
            }


            }


            validObject(object)
            return(object)
          }
)

