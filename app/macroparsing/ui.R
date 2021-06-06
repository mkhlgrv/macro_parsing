#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(macroparsing)
library(ggplot2)
library(dplyr)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("База данных для экономики России"),

    # Sidebar with a slider input for number of bins
    fluidRow(
        column(4,
               selectizeInput(
                   "ticker",
                   "Переменные:",
                   choices =#c('дол' = 'usd'),
                       {
                           x <- macroparsing::variables$ticker
                           names(x) <- macroparsing::variables$name_rus_short
                           x
                       },
                   selected = 'usd',
                   multiple = TRUE,
                   options = list(maxItems = 9)
                   ),
               dateRangeInput("daterange", "Date range:",
                              min = "1960-01-01",
                              start = "2000-01-01",
                              end   = lubridate::today() %>%
                                  as.character())
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plot")
        )
    )
))
