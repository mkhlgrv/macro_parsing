
dashboardPage(dashboardHeader(title="База данных для экономики России"),
              dashboardSidebar(  sidebarMenu(
                menuItem("График", tabName = "plot", icon = icon("dashboard")),
                menuItem("Описание переменных", tabName = "description", icon = icon("th"),
                         badgeLabel = "new", badgeColor = "green"),
                menuItem("Обновления", icon = icon("th"), tabName = "update",
                         badgeLabel = "new", badgeColor = "green")


              )
              ),
              dashboardBody(
                tabItems(
                  tabItem(tabName = "plot",
                          tabPanel("График",
                                   fluidRow(
                                     column(width=1,
                                            box(
                                              title = NULL, width = NULL,
                                              actionButton("add", "Добавить", icon = icon("plus")),
                                              br(),

                                              actionButton("remove", "Удалить", icon = icon("minus")),
                                              br(),

                                              actionButton("reset", "Очистить", icon = icon("trash")),
                                              br(),
                                              downloadButton('downloadData', 'Скачать')

                                     )),
                                     column(2,
                                            box(title=NULL, width=NULL, dateRangeInput("daterange", "Дата",
                                                               min = "1960-01-01",
                                                               separator = " - ",
                                                               language = "ru",
                                                               start = "2000-01-01",
                                                               end   = lubridate::today() %>%
                                                                 as.character()))
                                            ),

                                     mainPanel( plotOutput("plot")
                                     )

                                   )
                          )),
                  tabItem(tabName = "description",tabPanel("Описание переменных",
                                                    fluidRow(mainPanel((dataTableOutput("table"))))
                  )),
                  tabItem(tabName = "update",tabPanel("Обновление",
                                                    shinydashboard::infoBoxOutput("last_update")
                  )
                  )
    )),
    skin = "black")
