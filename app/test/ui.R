shinyUI(fluidPage(
  actionBttn("reset", "RESET", style="simple", size="sm", color = "warning"),
  actionBttn("add", "ADD", style="simple", size="sm", color = "warning"),
  verbatimTextOutput(outputId = "text")
))
