get.variables.df <- function(tickers=NULL, sources=NULL){

  failed_tickers <- tickers[which(!tickers %in%macroparsing::variables$ticker)]
  failed_sources <- sources[which(!sources %in%macroparsing::variables$source)]

  if(length(failed_tickers)!=0){
    message(paste0("Следующие тикеры не найдены: ",paste(failed_tickers, collapse = " ")))
  }
  if(length(failed_sources)!=0){
    message(paste0("Следующие источники не найдены: ",paste(failed_sources, collapse = " ")))
  }
  if(is.null(tickers)&is.null(sources)){
    out <- macroparsing::variables
  } else if(!is.null(tickers)&is.null(sources)){
    out <- macroparsing::variables %>%
      dplyr::inner_join(
        tibble::tibble(ticker = tickers),
        by = 'ticker')
  } else if(is.null(tickers)&!is.null(sources)){
   out <-  macroparsing::variables %>%
      dplyr::inner_join(
        tibble::tibble(source = sources),
        by = 'source'
      )
  } else if(!is.null(tickers)&!is.null(sources)){

    out <- rbind(macroparsing::variables %>%
            dplyr::inner_join(
              tibble::tibble(source = sources),
              by = 'source'
            ),
          macroparsing::variables %>%
            dplyr::inner_join(
              tibble::tibble(ticker = tickers),
              by = 'ticker'
            ))
  }
  out <- out[which(out$source!='rosstat1'),]

    if(length(which(out$source=='internal'))>0){

    dependecies <- macroparsing::internal_tickers %>%
      dplyr::inner_join(out, by = "ticker") %>%
      .$related_ticker
    dependecies_df <- macroparsing::variables %>%
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
  rosstat_tables <- dplyr::inner_join(macroparsing::rosstat_ticker_tables,
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
fill.folder <- function(tickers  = NULL, sources=NULL,
                     type=c("raw", "transform", "deseason")){

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



#' download
#'
#' Функция обновляет базу данных для определенных тикеров или источников. Если тикеры и источники не указаны, производится обновление всей базы данных, запись сырых данных в папку data/raw (файлы ticker.csv с тремя колонками: date, value, update_date),
#' запись использованных excel-файлов из Росстата в папку data/raw_excel (файлы .xls, .xlsx в исходном виде).
#'
#' Обратите внимание: в папку raw происходит запись таких комбинаций (date, value),
#'  которые до этого не встречались в таблице. Некоторые переменные, в частности индексы OECD и Индекс глобальной экономической активности, каждый месяц пересчитываются для всех значений.
#'
#'  Это означает, что соответствующие таблицы в папке raw будут полностью обновляться, однако старые значения удаляться не будут. Также следует учесть, что папка data/raw_excel
#'   потенциально может занимать достаточно много места,
#'  так как в ней хранятся все исходные excel-файлы, когда-либо использованные для скачивания данных с Росстата.
#'
#'  Папка raw состоит из нескольких подпапок, названных так же, как называются отдельные таблицы, которые можно получить с Росстата \code{macroparsing::rosstat_tables}.
#'   В каждой из подпапок сохраняются версии исходных файлов, названные по датам обновления файла на сайте Росстата.
#'
#'  В папке transform для каждого тикера представлена трансформированная версия временного ряда (таблица date, value): во-первых, для каждой даты есть только одно значение, соответствующее
#'  самому актуальном значению ряда. Во-вторых, дневные временные ряды переведены в среднее с начала месяца значение. В-третьих, те ряды, которые исходно представляются
#'  отностельно прошлого месяца (в частности, ИПЦ), переведены в цепные индексы.
#'
#'
#'
#' @param tickers строковый вектор тикеров из таблицы \code{macroparsing::show.variables()}
#' @param sources строковый вектор источников из таблицы \code{macroparsing::sources}
#' @param raw логическое выражение, если верно, то происходит запрос данных из внешних источников и обновляется содержимое папок data/raw/ и data/raw_excel.
#' @param transform логическое выражение, если верно, то на основе содержмого папки data/raw/ данные трансформируются и заполняется содержимое папки data/transform
#'
#' @export
#'
#' @examples
#' # Обновить все доступные временные ряды
#' download()
#' # Обновить ИПЦ (тикер cpi)
#' download(tickers = c("cpi"))
#' # Обновить все ряды из OECD (тикер источника oecd)
#' download(sources = c("oecd"))
#' # Обновить только сырые значения и не трансформировать их
#' download(transform = FALSE)
#' #' Обновить только папку transform, не загружая ряды из внешних источников
#' download(raw = FALSE)
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
