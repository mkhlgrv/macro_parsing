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
                   multiple = TRUE#,
                   # options = list(maxItems = 9)
                   ),
               selectizeInput(
                   "type",
                   "Тип данных:",
                   choices =
                       c("Исходный вид"="raw",
                         "Трансформированные" = "transform",
                         "Трансформированные и детрендированные" ="deseason"),
                   selected = "deseason",
                   multiple = FALSE
               ),
               dateRangeInput("daterange", "Дата",
                              min = "1960-01-01",
                              separator = " - ",
                              language = "ru",
                              start = "2000-01-01",
                              end   = lubridate::today() %>%
                                  as.character()),
               downloadButton('downloadData', 'Загрузить')
        ),

        mainPanel(
            plotOutput("plot")
        )
    )
))
