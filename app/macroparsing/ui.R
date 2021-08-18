


shinyUI(
    navbarPage("База данных для экономики России",
               tabPanel("График",
                        fluidRow(
                            column(1,
                                   actionButton("add", "Добавить", icon = icon("plus")),
                                   actionButton("remove", "Удалить", icon = icon("minus")),
                                   actionButton("reset", "Очистить", icon = icon("trash")),
                                   hr(),
                                   downloadButton('downloadData', 'Загрузить', )
                            ),
                            column(2,
                                   dateRangeInput("daterange", "Дата",
                                                  min = "1960-01-01",
                                                  separator = " - ",
                                                  language = "ru",
                                                  start = "2000-01-01",
                                                  end   = lubridate::today() %>%
                                                      as.character())),

                            mainPanel( plotOutput("plot")
                                )

                            )
                        ),
               tabPanel("Описание переменных",
                        fluidRow(mainPanel((dataTableOutput("table"))))
                        )
    )
)
