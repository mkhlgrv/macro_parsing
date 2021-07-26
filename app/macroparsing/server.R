
shinyServer(function(input, output) {

  get.data.from.csv <- function(tickers){
    tickers %>%
    purrr::map_dfr(function(ticker){
      data.table::fread(paste0(Sys.getenv('directory'),"/data/",input$type,"/",
                               ticker, '.csv'),
                        select = c('date', 'value')) %>%
        dplyr::mutate(ticker = ticker) %>%
        na.omit #%>%
        # dplyr::group_by(zoo::as.yearmon(date)) %>%
        # dplyr::mutate(cm_value = cummean(value)) %>%
        # dplyr::mutate(mean_value = mean(value)) %>%
        # dplyr::ungroup() %>%
        # dplyr::mutate(rm_value = zoo::rollmean(value, k = 23, fill = NA, align = "right"))
    }) %>%
      inner_join(macroparsing::variables[,
                                         c('ticker', 'name_rus_short')],
                 by ='ticker')


  }

  output$downloadData <- downloadHandler(
      filename = function() {
        paste('data-', Sys.Date(), '.csv', sep='')
      },
      content = function(con) {
          data.table::fwrite(get.data.from.csv(input$ticker), con)
      }
    )
    output$plot <- renderPlot({

      if(length(input$ticker)>0){
        get.data.from.csv(input$ticker) %>%
          filter(date >= input$daterange[1],
                 date <= input$daterange[2],) %>%
          ggplot(aes(x=date, y =value))+
          geom_line()+
          # geom_line(aes(y=cm_value, color='cummean'))+
          # geom_line(aes(y=rm_value, color='rollmean'))+
          theme_minimal()+
          labs(x='Дата', y ='Значение')+
          facet_wrap(vars(name_rus_short), scales = 'free_y')
      }





    })

})
