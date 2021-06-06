#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$plot <- renderPlot({

        data.table::fread(paste0("C:/Users/mkhlgrv/Documents/macroparsing_usage/data/raw/",
                                 input$ticker, '.csv'),
                          select = c('date', 'value')) %>%
            ggplot(aes(x=date, y =value))+
            geom_line()+
            theme_minimal()

    })

})
