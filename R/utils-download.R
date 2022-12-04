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
                     folder = c("raw", "tf")){


  variables_df <- get.variables.df(tickers=tickers, sources=sources)






  if(folder == "raw"){

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
        purrr::walk(process.by.ticker,
                    source = source,
                    download = folder=="raw",
                    transform = folder=="tf",
                    pb = pb
                    )
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
#' @export
download <- function(tickers  = NULL,
                     sources=NULL,
                     raw = TRUE,
                     transform = TRUE){

  check.log.file()

  if(raw){
    fill.folder(tickers=tickers, sources=sources, folder='raw')
  }

  if(transform){
    fill.folder(tickers=tickers, sources=sources, folder='tf')
  }
  # метаданные
  write.csv(rmedb::get.variables.df(), file=paste0(Sys.getenv('directory'), '/data/metadata.csv'),fileEncoding = "UTF-8",  row.names = FALSE)

}



process.by.ticker <- function(ticker,source, download= TRUE, transform = TRUE, pb = NULL){
  if(!is.null(pb)){
    pb$tick()
  }

  out <- tryCatch({
    object <- new(source, ticker)
    if(download){
      object <- object %>%
        download.ts() %>%
        write.ts()
    }
    if(transform){
      object <- object %>%
        transform.ts() %>%
        write.ts.tf()
    }
    log.by.ticker(object)
  },
  error = function(e){
    paste0(Sys.time(),
           " ",ticker,": ",gsub("\n","",e))
  },
  warning=function(w){
    paste0(Sys.time(),
           " ",ticker,": ",gsub("\n","",w))
  },
  finally =  "")

  write(out,file=Sys.getenv("log_file"),append=TRUE, sep = "")
}




process.by.table <- function(tab, pb = NULL){
  if(!is.null(pb)){
    pb$tick()
  }


  out <- tryCatch({

    object <- new("rosstat_table", tab) %>%
      modified()%>%
      source.modified() %>%
      find.url() %>%
      download.from.url()
    log.by.table(object)
  },
  error = function(e){
    paste0(Sys.time(),
           " ",tab,": ",gsub("\n","",e))
  },
  warning=function(w){
    paste0(Sys.time(),
           " ",tab,": ",gsub("\n","",w))
  },
  finally =  "")

  write(out,file=Sys.getenv("log_file"),append=TRUE, sep = "")
}

download.rosstat.tables <- function(variables_df){

  rosstat_tabs <- dplyr::inner_join(rmedb::rosstat_ticker_tables,
                                      variables_df, by = "ticker") %>%
    .$table %>%
    unique


  pb <- progress::progress_bar$new(total = length(rosstat_tabs),
                                   format = "[:bar] :percent :eta")

  purrr::walk(rosstat_tabs,process.by.table, pb)
}
