download.by.ticker <-  function(object, .ticker) {
  UseMethod("download.by.ticker")
}
setMethod(
  "download.by.ticker", "cbr",
  function(object, .ticker) {
    object <-  object%>%
    ticker(.ticker) %>%
        freq() %>%
        observation.start() %>%
        use.archive() %>%
        previous.date.till() %>%
        date.from() %>%
        cbr.ticker() %>%
        url() %>%
        download.ts() %>%
        write.ts()
    validObject(object)
    return(object)
  }
)

setMethod(
  "download.by.ticker", "moex",
  function(object, .ticker) {
    object <-  object%>%
        ticker(.ticker) %>%
        observation.start %>%
        use.archive %>%

        previous.date.till %>%
        date.from %>%

        download.ts %>%
        write.ts
    validObject(object)
    return(object)
  }
)

setMethod(
  "download.by.ticker", "fred",
  function(object, .ticker) {
    object <-  object%>%
      ticker(.ticker) %>%
        freq %>%
        observation.start %>%
        use.archive %>%
        previous.date.till %>%
        date.from %>%
        download.ts%>%
        write.ts
    validObject(object)
    return(object)
  }
)

setMethod(
  "download.by.ticker", "oecd",
  function(object, .ticker) {
    object <-  object%>%
      ticker(.ticker) %>%
      observation.start %>%
        use.archive %>%
        previous.date.till %>%
        date.from %>%
        oecd.ticker %>%
        url %>%
        download.ts%>%
        write.ts
    validObject(object)
    return(object)
  }
)
setMethod(
  "download.by.ticker", "dallasfed",
  function(object, .ticker) {
    object <-  object%>%
      ticker(.ticker) %>%
        observation.start %>%
        use.archive %>%
        previous.date.till %>%
        date.from %>%
        url %>%
        download.ts%>%
        write.ts
    validObject(object)
    return(object)
  }
)

setMethod(
  "download.by.ticker", "rosstat",
  function(object, .ticker) {
    object <-  object%>%
      ticker(.ticker) %>%
      observation.start %>%
      use.archive %>%
      previous.date.till %>%
      date.from %>%
      table %>%
      url %>%
      ext %>%
      pattern %>%
      file.url %>%
      sheet.info %>%
      download.ts%>%
      write.ts
    validObject(object)
    return(object)
  }
)
