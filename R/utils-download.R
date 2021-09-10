get.variables.df <- function(tickers=NULL, sources=NULL){
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

    internal_n <- which(out$source=='internal')
    not_internal_n <- which(out$source!='internal')
    if(length(internal_n)>0 & length(not_internal_n)>0){
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

  variables_df %>%
      split(.$source) %>%
    iwalk_fun(function(x, source){
        x %>%
          split(.$ticker) %>%
          names %>%
        walk_fun(function(ticker, source){
            new(source) %>%
            by_tiker_fun(ticker)
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
                     transform_and_deseason = TRUE){

  if(raw){
    fill.folder(tickers=tickers, sources=sources, use_future=use_future, type='raw')
  }

  if(transform_and_deseason){
    fill.folder(tickers=tickers, sources=sources, use_future=use_future, type='transform')
    fill.folder(tickers=tickers, sources=sources, use_future=use_future, type='deseason')
  }

}
