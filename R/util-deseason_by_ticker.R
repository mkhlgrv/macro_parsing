
deseason.by.ticker <-  function(object, .ticker) {
  UseMethod("deseason.by.ticker")
}
setMethod(
  "deseason.by.ticker", "parsed_ts",
  function(object, .ticker) {
    print(.ticker)
    object <-  object%>%
      ticker(.ticker) %>%
      freq() %>%
      deseason() %>%
      deseason.ts() %>%
      write.deseason.ts()
    validObject(object)
    return(object)
  }
)
