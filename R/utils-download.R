#' Variables dataframe
#'
#' Возвращает data.frame, отфильтрованный по указанным тикерам и источникам.
#'
#' @param tickers character, список допустимых тикеров, см. \link[rmedb]{show.variables}
#' @param sources character, список допустимых имен источников, см. \link[rmedb]{sources}
#'
#' @return data.frame, tibble
#' @export
#' @keywords internal
#'
#' Если были указаны тикеры, принадлежащие к источнику internal (не скачиваемые напрямую, а рассчитываемые на основе других рядов), то
#' сначала скачиваются все зависимые временные ряды, и только после их обновления происходит запись новых значений тикеров из источника internal.
#'
get.variables.df <- function(tickers=NULL, sources=NULL){

  failed_tickers <- tickers[which(!tickers %in%rmedb::variables$ticker)]
  failed_sources <- sources[which(!sources %in%rmedb::variables$source)]

  if(length(failed_tickers)!=0){
    message(paste0("Следующие тикеры не найдены: ",paste(failed_tickers, collapse = " ")))
  }
  if(length(failed_sources)!=0){
    message(paste0("Следующие источники не найдены: ",paste(failed_sources, collapse = " ")))
  }

  if(is.null(tickers)&is.null(sources)){
    out <- rmedb::variables
  } else if(!is.null(tickers)&is.null(sources)){
    out <- rmedb::variables %>%
      dplyr::inner_join(
        tibble::tibble(ticker = tickers),
        by = 'ticker')
  } else if(is.null(tickers)&!is.null(sources)){
   out <-  rmedb::variables %>%
      dplyr::inner_join(
        tibble::tibble(source = sources),
        by = 'source'
      )
  } else if(!is.null(tickers)&!is.null(sources)){

    out <- rbind(rmedb::variables %>%
            dplyr::inner_join(
              tibble::tibble(source = sources),
              by = 'source'
            ),
          rmedb::variables %>%
            dplyr::inner_join(
              tibble::tibble(ticker = tickers),
              by = 'ticker'
            ))
  }
  out <- out[which(out$source!='rosstat1'),]

    if(length(which(out$source=='internal'))>0){

    dependecies <- rmedb::internal_tickers %>%
      dplyr::inner_join(out, by = "ticker") %>%
      .$related_ticker
    dependecies_df <- rmedb::variables %>%
      dplyr::inner_join(
        tibble::tibble(ticker = dependecies),
        by = 'ticker'
      )

    out <- rbind(out, dependecies_df) %>%
      unique()

    internal_n <- which(out$source=='internal')
    not_internal_n <- which(out$source!='internal')

      out[c(not_internal_n,
            internal_n),
      ]

    } else{
      out
    }
}
download.rosstat.tables <- function(variables_df){
  rosstat_tables <- dplyr::inner_join(rmedb::rosstat_ticker_tables,
                                      variables_df, by = "ticker") %>%
    .$table %>%
    unique


  pb <- progress::progress_bar$new(total = length(rosstat_tables),
                                   format = "[:bar] :percent :eta")
  purrr::walk(rosstat_tables,
              function(table){
                pb$tick()
                new("rosstat_table", table) %>%
                  modified()%>%
                  source.modified() %>%
                  find.url() %>%
                  download.from.url()
              })
}

#' Update specified folder
#'
#' Обновляет файлы для указанных тикеров и источников в указанной папке type.
#'
#' @param tickers character, список допустимых тикеров см. \code{rmedb::show.variables()}
#' @param sources character, список допустимых имен источников см. \code{rmedb::sources}
#' @param type character: "raw", "transform"
#'
#' @return
#' @export
#' @keywords internal
fill.folder <- function(tickers  = NULL, sources=NULL,
                     type=c("raw", "transform")){

  check.files(type=type)

  variables_df <- get.variables.df(tickers=tickers, sources=sources)



  by_tiker_fun <- switch(type,
                         raw = download.by.ticker,
                         transform = transform.by.ticker,
                         deseason = deseason.by.ticker)



  if(type == "raw"){



    log_file <- paste0(Sys.getenv('directory'),'/data/log/',format(Sys.time(), '%Y_%m_%d_%H_%M_%S'),'.log')
    file.create(log_file)

    download.rosstat.tables(variables_df)


  }

  pb <- progress::progress_bar$new(total = nrow(variables_df),
                                   format = "[:bar] :percent :eta")


  variables_df %>%
      split(factor(.$source, levels = unique(.$source))) %>%
    purrr::iwalk(function(x, source){
        x %>%
          split(.$ticker) %>%
          names %>%
        purrr::walk(function(ticker, source){
          pb$tick()
          tryCatch({
            result <- new(source) %>%
              by_tiker_fun(ticker)
            if(type == "raw"){
              n = nrow(result@ts)

            write(c(paste(ticker,
                          ": ",
                          n,
                          " rows downloaded"
                          )),
                  file=log_file,
                  sep ="",
                  append=TRUE)
            }
          }
            ,
            error= function(cond){

              if(type == "raw"){
              write(c(paste(ticker,
                            ": ",
                            cond)),
                    file=log_file,
                    sep ="",
                    append=TRUE)
              }

              return(NULL)
            }


          )

          }, source = source)
      })

}
#' Update database
#'
#' Получает обновления данных для указанных временных рядов (ticker) или всех временных рядов из указанных источников (source) и записывает их в рабочую директорию пакета.
#' Если тикеры и источники не указаны, производится обновление всей базы данных.
#'
#'
#' @param tickers character список допустимых тикеров см. см. \link[rmedb]{show.variables}
#' @param sources character список допустимых имен источников см. \link[rmedb]{sources}
#' @param raw logical, при TRUE происходит запрос данных из внешних источников и обновляется содержимое папок data/raw/ и data/raw_excel
#' @param transform logical, при TRUE на основе содержмого папки data/raw/ данные трансформируются и заполняется содержимое папки data/tf
#'
download <- function(tickers  = NULL,
                     sources=NULL,
                     raw = TRUE,
                     transform = TRUE){

  if(raw){
    fill.folder(tickers=tickers, sources=sources, type='raw')
  }

  if(transform){
    fill.folder(tickers=tickers, sources=sources, type='transform')
  }

}
