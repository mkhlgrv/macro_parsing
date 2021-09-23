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
fill.folder <- function(tickers  = NULL, sources=NULL, use_future=FALSE,
                     type=c("raw", "transform", "deseason")){

  check.files(type=type)

  variables_df <- get.variables.df(tickers=tickers, sources=sources)

  if(use_future){
    future::plan(future::multisession())
    iwalk_fun <- furrr::future_iwalk
    walk_fun <- furrr::future_walk
  } else{
    iwalk_fun <- purrr::iwalk
    walk_fun <- purrr::walk
  }

  by_tiker_fun <- switch(type,
                         raw = download.by.ticker,
                         transform = transform.by.ticker,
                         deseason = deseason.by.ticker)



  if(type == "raw"){



    log_file <- paste0(Sys.getenv('directory'),'/data/log/',format(Sys.time(), '%Y_%m_%d_%H_%M_%S'),'.log')
    file.create(log_file)

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

  pb <- progress::progress_bar$new(total = nrow(variables_df),
                                   format = "[:bar] :percent :eta")


  variables_df %>%
      split(factor(.$source, levels = unique(.$source))) %>%
    iwalk_fun(function(x, source){
        x %>%
          split(.$ticker) %>%
          names %>%
        walk_fun(function(ticker, source){
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



#' Title
#'
#' @param tickers
#' @param sources
#' @param use_future
#' @param transform_and_deseason
#'
#' @return
#' @export
#'
#' @examples
download <- function(tickers  = NULL,
                     sources=NULL,
                     use_future=FALSE,
                     raw = TRUE,
                     transform = TRUE){

  if(raw){
    fill.folder(tickers=tickers, sources=sources, use_future=use_future, type='raw')
  }

  if(transform){
    fill.folder(tickers=tickers, sources=sources, use_future=use_future, type='transform')
  }

}
