library(shiny)
library(macroparsing)
library(ggplot2)
library(dplyr)


shinyUI(fluidPage(

    titlePanel("База данных для экономики России"),

    fluidRow(
        column(4,
               selectizeInput(
                   "ticker",
                   "Переменные:",
                   choices =
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

        mainPanel(
            plotOutput("plot")
        )
    )
))
