
shinyServer(function(input, output) {

  ticker_to_show <- reactiveValues()

  freqs <- reactive({
    if(is.null(input$ticker)){
        NULL
      } else{
        freq_choices_num <-  c(1,4,12,52,252)
        freq_choices_name <- c("Год" = "y",
                               "Квартал"="q",
                               "Месяц"="m",
                               "Неделя"="w",
                               "День"="d")

        freq_start <- macroparsing::variables %>%
          .[which(.$ticker==input$ticker),freq] %>%
          as.character()%>%
          switch(
            'q' = 4,
            'm'=12,
            'w' = 52,
            "d" = 252)

        freq_choices_name[which(freq_choices_num<=freq_start)] %>% rev()
      }
  })


  observeEvent(input$reset, {
    # display a modal dialog with a header, textinput and action buttons
    showModal(modalDialog(
      tags$h2('Очистить выбор'),
      footer=tagList(
        actionButton('submit_reset', 'Подтвердить'),
        modalButton('Отменить')
      )
    ))
  })

  observeEvent(input$add, {
    # display a modal dialog with a header, textinput and action buttons
    showModal(modalDialog(
      tags$h2('Добавить переменную'),
      checkboxInput("only_main", "Показать только важные переменные", FALSE),
      uiOutput("variables_input"),
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
      uiOutput("frequency_input")
      ,
      renderPlot({

        if(length(input$ticker)>0 & length(input$freq)>0){
          get.data.from.csv(input$ticker, input$type,input$freq,
                            input$daterange[1], input$daterange[2]) %>%
            ggplot(aes(x=date, y =value))+
            geom_line()+
            # geom_line(aes(y=cm_value, color='cummean'))+
            # geom_line(aes(y=rm_value, color='rollmean'))+
            theme_minimal()+
            labs(x='Дата', y ='Значение')+
            facet_wrap(vars(name_rus_short), scales = 'free_y')
        }





      }),
      footer=tagList(
        actionButton('submit_add_more', 'Добавить ещё'),
        actionButton('submit_add', 'Добавить и завершить'),
        modalButton('Отменить')
      )
    ))
  })

  observeEvent(input$remove, {
    showModal(modalDialog(
      tags$h2('Удалить переменную'),

      checkboxGroupInput(
        "tickers_to_remove",
        "Переменные:",
        choices = {
          if(length(ticker_to_show$ticker)==0){
            NULL
          } else{
            x <- 1:length(ticker_to_show$ticker)
            names(x) <- macroparsing::variables %>%
              inner_join(tibble(ticker=ticker_to_show$ticker), by = "ticker") %>%
              .$name_rus_short
            x
          }
          },
      )
      ,
      footer=tagList(
        actionButton('submit_remove', 'Подтвердить'),
        modalButton('Отменить')
      )
    ))
  })

  observeEvent(input$submit_reset, {
    removeModal()
    ticker_to_show$ticker <- NULL
    ticker_to_show$type <- NULL
    # ticker_to_show$daterange_start <- NULL
    # ticker_to_show$daterange_end <- NULL
  })

  observeEvent(input$submit_add, {
    removeModal()
    if((input$ticker %in% ticker_to_show$ticker) &
       (input$type %in% ticker_to_show$type) &
       (input$freq %in% ticker_to_show$freq)
       ){
      showNotification("Вы уже добавили такую коминацию параметров для этой переменной.")
    } else {
      ticker_to_show$ticker <- c(ticker_to_show$ticker, input$ticker)
      ticker_to_show$type <- c(ticker_to_show$type, input$type)
      ticker_to_show$freq <- c(ticker_to_show$freq, input$freq)
    }


    # ticker_to_show$daterange_start <- c(ticker_to_show$daterange_start, input$daterange[1])
    # ticker_to_show$daterange_end <- c(ticker_to_show$daterange_end, input$daterange[2])
  })

  observeEvent(input$submit_add_more, {
    if((input$ticker %in% ticker_to_show$ticker) &
       (input$type %in% ticker_to_show$type) &
       (input$freq %in% ticker_to_show$freq)
       ){
      showNotification("Вы уже добавили такую коминацию параметров для этой переменной.")
    } else {
      ticker_to_show$ticker <- c(ticker_to_show$ticker, input$ticker)
      ticker_to_show$type <- c(ticker_to_show$type, input$type)
      ticker_to_show$freq <- c(ticker_to_show$freq, input$freq)
    }
    # ticker_to_show$daterange_start <- c(ticker_to_show$daterange_start, input$daterange[1])
    # ticker_to_show$daterange_end <- c(ticker_to_show$daterange_end, input$daterange[2])
  })

  observeEvent(input$submit_remove, {
    removeModal()
    if(length(input$tickers_to_remove)>0){
      n_to_remove <- as.integer(input$tickers_to_remove)
      ticker_to_show$ticker <- ticker_to_show$ticker[-n_to_remove]
      ticker_to_show$type <- ticker_to_show$type[-n_to_remove]
      ticker_to_show$freq <- ticker_to_show$freq[-n_to_remove]
      # ticker_to_show$daterange_start <- ticker_to_show$daterange_start[-n_to_remove]
      # ticker_to_show$daterange_end <- ticker_to_show$daterange_end[-n_to_remove]
    }

  })




  output$downloadData <- downloadHandler(
      filename = function() {
        paste('data-', Sys.Date(), '.csv', sep='')
      },
      content = function(con) {
        len <- length(ticker_to_show$ticker)
          data.table::fwrite(get.data.from.csv(ticker_to_show$ticker,
                                               ticker_to_show$type,
                                               ticker_to_show$freq,
                                               rep(input$daterange[1],len),
                                               rep(input$daterange[2], len)),
                             con)
      }
    )
    output$plot <- renderPlot({

      if(length(ticker_to_show$ticker)>0){

        len <- length(ticker_to_show$ticker)

        get.data.from.csv(ticker_to_show$ticker,
                          ticker_to_show$type,
                          ticker_to_show$freq,
                          rep(input$daterange[1],len),
                          rep(input$daterange[2], len)
                          ) %>%
          ggplot(aes(x=date, y =value))+
          geom_line()+
          theme_minimal()+
          labs(x='Дата', y ='Значение')+
          facet_wrap(vars(name_rus_short, type, freq), scales = 'free_y')
      }





    })

    output$table <- renderDataTable({
      macroparsing::variables[,c("name_rus_short","observation_start", "freq", "source")] %>%
        inner_join(macroparsing::sources[,c("source", "name_rus_short")], by = "source") %>%
        select(-source) %>%
        dplyr::rename(Переменная="name_rus_short",
                                "Начало наблюдений" = "observation_start",
                                "Периодичность" = 'freq',
                                "Источник" = "description")
      }

    )



#
    output$frequency_input <- renderUI( {

      selectizeInput("freq","Периодичность",choices= freqs(), selected=1)
    })

    output$variables_input <- renderUI( {

      selectizeInput(
        "ticker",
        "Переменные:",
        choices ={
          if(input$only_main){
          x <- macroparsing::variables$ticker
          names(x) <- macroparsing::variables$name_rus_short


          x[which(x %in% c("usd", "gdp_real", "gdp_nom", "DCOILBRENTEU"))]

          } else{
            split({
              x <- macroparsing::variables$ticker
              names(x) <- macroparsing::variables$name_rus_short
              x

            },
            macroparsing::variables$source
            )
          }

        }
          ,
        selected = 'usd',
        multiple = FALSE
      )
    })



    get.data.from.csv <-
      function(ticker, type,
               freq,
               daterange_start, daterange_end){
        1:length(ticker) %>%
          purrr::map_dfr(function(i){
            .ticker <- ticker[i]
            .type <- type[i]
            .freq <- freq[i]
            .daterange <- c(daterange_start[i],
                            daterange_end[i] )

            freq_start <- macroparsing::variables %>%
              .[which(.$ticker==.ticker),freq]



            k <- switch(.freq,#.freq,
                        "y"=1,
                        'q' = 4,
                        'm'=12,
                        'w' = 52,
                        "d" = 252)

            fun_to_aggregate <- function(x){

              if(freq_start==.freq){
                x
              } else {
                aggregate <- macroparsing::variables %>%
                  .[which(.$ticker==.ticker),aggregate]
                # sum mean prod
                if(aggregate=="sum"){
                  fun_lambda <- sum
                } else if(aggregate=="mean"){
                  fun_lambda <- mean
                }
                else if(aggregate=="prod"){
                  fun_lambda <- cumprod
                }
                else if(aggregate=="last"){
                  fun_lambda <- last
                }



                if(aggregate=="prod"){
                  x$value <- x$value/100
                }
                if(.freq=="w"){
                  x <- x %>%
                    dplyr::mutate(date = get.next.weekday(date, "Пт",0))
                } else if(freq=='m'){
                  x <- x %>%
                    dplyr::mutate(date = zoo::as.yearmon(date) %>% zoo::as.Date())
                } else if(freq=='q'){
                  x <- x %>%
                    dplyr::mutate(date = zoo::as.yearqtr(date)%>% zoo::as.Date())
                } else if(freq=='y'){
                  x <- x %>%
                    dplyr::mutate(date = as.Date(paste0(year(date), "-01-01")))
                }
                    x %>%
                      dplyr::group_by(date) %>%
                    dplyr::summarise(value = fun_lambda(value))

                }
              }

            fun_to_transfrom <- function(x){
              if(.type=="level"){
                x
              } else if(.type=="logdiff"){
                x %>%  dplyr::mutate(value=xts::diff.xts(value,
                                                         lag = 1,
                                                         log=TRUE))
              }else if(.type=="logdiff4"){
                x %>%  dplyr::mutate(value=xts::diff.xts(value,
                                                         lag = k,
                                                         log=TRUE))
              }else if(.type=="diff"){
                x %>%  dplyr::mutate(value=xts::diff.xts(value,
                                                         lag = 1))
              }else if(.type=="diff4"){
                x %>%  dplyr::mutate(value=xts::diff.xts(value,
                                                         lag = k))
              }
            }

            type_name <- switch(.type,
                  "level"="В уровнях",
              "logdiff"="Темп роста к предыдущему периоду" ,
               "logdiff4"="Темп роста к аналогичному периоду прошлого году",
             "diff"= "Изменение к предыдущему периоду",
              "diff4"="Изменение к аналогичному периоду прошлого году")

            freq_name <- switch(.freq,
                            "y"="Год",
                              "q"="Квартал",
                              "m"="Месяц",
                              "w"="Неделя",
                              "d"="День")


            data.table::fread(paste0(Sys.getenv('directory'),"/data/","raw","/",
                                     .ticker, '.csv'),
                              select = c('date', 'value', "update_date")) %>%
              dplyr::group_by(date) %>%
              dplyr::summarise(value = last(value)) %>%
              na.omit %>%
              fun_to_aggregate() %>%
              fun_to_transfrom() %>%
              dplyr::mutate(ticker = .ticker,
                            type = type_name,
                            freq = freq_name
              ) %>%
              na.omit %>%
              filter(date >= .daterange[1],
                     date <= .daterange[2])
            # dplyr::group_by(zoo::as.yearmon(date)) %>%
            # dplyr::mutate(cm_value = cummean(value)) %>%
            # dplyr::mutate(mean_value = mean(value)) %>%
            # dplyr::ungroup() %>%
            # dplyr::mutate(rm_value = zoo::rollmean(value, k = 23, fill = NA, align = "right"))
          }
    ) %>%
          inner_join(macroparsing::variables[,
                                             c('ticker', 'name_rus_short')],
                     by ='ticker')


      }
})





