transform.by.ticker <-  function(object, .ticker) {
  UseMethod("transform.by.ticker")
}
setMethod(
  "transform.by.ticker", "parsed_ts",
  function(object, .ticker) {
    object <-  object%>%
      ticker(.ticker) %>%
      transform() %>%
      transform.ts() %>%
      write.transform.ts()
    validObject(object)
    return(object)
  }
)
