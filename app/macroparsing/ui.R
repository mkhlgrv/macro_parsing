library(shiny)
library(macroparsing)
library(ggplot2)
library(dplyr)


shinyUI(fluidPage(

    titlePanel("База данных для экономики России"),

    fluidRow(
        column(3,
                actionButton("add", "Добавить", icon = icon("plus")),
               actionButton("remove", "Удалить", icon = icon("minus")),
               actionButton("reset", "Очистить", icon = icon("trash")),
               hr(),
               downloadButton('downloadData', 'Загрузить', )
        ),
        column(3,
               dateRangeInput("daterange", "Дата",
                              min = "1960-01-01",
                              separator = " - ",
                              language = "ru",
                              start = "2000-01-01",
                              end   = lubridate::today() %>%
                                  as.character())),

        mainPanel(
            plotOutput("plot")
        )
    )
))
