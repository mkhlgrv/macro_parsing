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
  ticker('cli_RUS') %>%
  observation.start %>%
  oecd.ticker %>%
  url %>%
  download.ts%>%
  write.ts

new('igrea') %>%
  ticker('igrea') %>%
  observation.start %>%
  url %>%
  download.ts%>%
  write.ts

  
new('cbr') %>%
  ticker('export_usd') %>%
  freq %>%
  observation.start %>%
  previous.date.till %>%
  date.from %>% 
  cbr.ticker %>%
  url %>%
  download.ts %>%
  write.ts()




