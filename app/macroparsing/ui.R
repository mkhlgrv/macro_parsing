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
               selectInput("ticker",
                           "Переменные:",
                           choices = macroparsing::variables$ticker,
                           selected = 'usd',
                           multiple = FALSE
                            )
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plot")
        )
    )
))
