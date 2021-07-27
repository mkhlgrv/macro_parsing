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
                       split({
                           x <- macroparsing::variables$ticker
                           names(x) <- macroparsing::variables$name_rus_short
                           x
                       },
                       macroparsing::variables$source
                       ),
                   selected = 'usd',
                   multiple = TRUE#,
                   # options = list(maxItems = 9)
                   ),
               selectizeInput(
                   "type",
                   "Представление данных:",
                   choices =
                       c("В уровнях"="level",
                         "Темп роста к предыдущему периоду" = "logdiff",
                         "Темп роста к аналогичному периоду прошлого году" ="logdiff4",
                         "Изменение к предыдущему периоду" = "diff",
                         "Изменение к аналогичному периоду прошлого году" = "diff4"),
                   selected = "level",
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
