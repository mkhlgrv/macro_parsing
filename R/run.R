library(dplyr)
# library(data.table)
# library(future)
# library(purrr)
# plan(multisession)
# MOEX

check.raw.files()
new('moex') %>%
  ticker('IMOEX') %>%
  observation.start %>%
  previous.date.till %>%
  date.from %>%
  download.ts %>%
  write.ts

new('fred') %>%
  ticker('SP500') %>%
  freq %>%
  observation.start %>%
  previous.date.till %>%
  date.from %>%
  download.ts%>%
  write.ts


new('oecd') %>%




