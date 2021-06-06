

shinyServer(function(input, output) {

  get.data.from.csv <- function(tickers){
    tickers %>%
    purrr::map_dfr(function(ticker){
      data.table::fread(paste0(Sys.getenv('directory'),"/data/raw/",
                               ticker, '.csv'),
                        select = c('date', 'value')) %>%
        dplyr::mutate(ticker = ticker)
    }) %>%
      inner_join(macroparsing::variables[,
                                         c('ticker', 'name_rus_short')],
                 by ='ticker')


  }
    output$plot <- renderPlot({


      get.data.from.csv(input$ticker) %>%
        filter(date >= input$daterange[1],
               date <= input$daterange[2],) %>%
            ggplot(aes(x=date, y =value))+
            geom_line()+
            theme_minimal()+
        labs(x='Дата', y ='Значение')+
        facet_wrap(vars(name_rus_short), scales = 'free_y')



    })

})
