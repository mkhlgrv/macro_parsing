#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  get.data.from.csv <- function(tickers){
    tickers %>%
    purrr::map_dfr(function(ticker){
      data.table::fread(paste0(Sys.getenv('directory'),"/data/raw/",
                               ticker, '.csv'),
                        select = c('date', 'value')) %>%
        dplyr::mutate(ticker = ticker)
    })


  }
    output$plot <- renderPlot({


      get.data.from.csv(input$ticker) %>%
            ggplot(aes(x=date, y =value))+
            geom_line()+
            theme_minimal()+
        facet_wrap(vars(ticker), scales = 'free_y')



    })

})
