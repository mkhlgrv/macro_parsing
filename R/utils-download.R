#' Title
#'
#' @param tickers
#' @param sources
#' @param use_future
#'
#' @return
#' @export
#'
#' @examples
download <- function(tickers  = NULL, sources=NULL, use_future=FALSE){

  if(is.null(tickers)&is.null(sources)){
    variables_df <- macroparsing::variables
  } else if(!is.null(tickers)&is.null(sources)){
    variables_df <- macroparsing::variables %>%
      dplyr::inner_join(
        tibble::tibble(ticker = tickers),
               by = 'ticker')
  } else if(is.null(tickers)&!is.null(sources)){
    variables_df <- macroparsing::variables %>%
      dplyr::inner_join(
        tibble::tibble(source = sources),
                       by = 'source'
      )
  } else if(!is.null(tickers)&!is.null(sources)){

    variables_df <- rbind(macroparsing::variables %>%
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

  if(use_future){
    future::plan(future::multisession())
    iwalk_fun <- furrr::future_iwalk
    walk_fun <- furrr::future_walk
  } else{
    iwalk_fun <- purrr::iwalk
    walk_fun <- purrr::walk
  }
  variables_df %>%
      split(.$source) %>%
    iwalk_fun(function(x, source){
        x %>%
          split(.$ticker) %>%
          names %>%
        walk_fun(function(ticker, source){
            new(source) %>%
              download.by.ticker(ticker)
          }, source = source)
      })



}
