
shinyServer(function(input, output, session) {
      l <- reactiveValues()
      observeEvent(input$reset, {
        # display a modal dialog with a header, textinput and action buttons
        showModal(modalDialog(
          tags$h2('Please enter your personal information'),
          textInput('name', 'Name'),
          textInput('state', 'State'),
          footer=tagList(
            actionButton('submit_reset', 'Submit'),
            modalButton('cancel')
          )
        ))
      })

      observeEvent(input$add, {
        # display a modal dialog with a header, textinput and action buttons
        showModal(modalDialog(
          tags$h2('Please enter your personal information'),
          textInput('name', 'Name'),
          textInput('state', 'State'),
          footer=tagList(
            actionButton('submit_add', 'Submit'),
            modalButton('cancel')
          )
        ))
      })

      # only store the information if the user clicks submit
      observeEvent(input$submit_reset, {
        removeModal()
        l$name <- input$name
        l$state <- input$state
      })

      observeEvent(input$submit_add, {
        removeModal()
        l$name <- c(l$name, input$name)
        l$state <- c(l$state, input$state)
      })

      # display whatever is listed in l
      output$text <- renderPrint({
        if (is.null(l$name)) return(NULL)
        paste('Name:', l$name, 'and state:', l$state)
      })
    }
  )
