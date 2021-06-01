# MOEX
new('moex') %>%
  ticker('IMOEX') %>%
  observation.start %>%
  previous.date.till %>%
  date.from %>%
  download.ts %>%
  write.ts