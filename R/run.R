# library(dplyr)
# # library(data.table)
# # library(future)
# # library(purrr)
# # plan(multisession)
# # MOEX
#
# check.raw.files()
# new('moex') %>%
#   ticker('IMOEX') %>%
#   observation.start %>%
#   use.archive %>%
#   previous.date.till %>%
#   date.from %>%
#   download.ts %>%
#   write.ts
#
new('fred') %>%
  ticker('SP500') %>%
  freq %>%
  observation.start %>%
  use.archive %>%
  previous.date.till %>%
  date.from %>%
  download.ts%>%
  write.ts
#
#
# new('oecd') %>%
#   ticker('cli_RUS') %>%
#   observation.start %>%
#   use.archive %>%
#   oecd.ticker %>%
#   url %>%
#   download.ts%>%
#   write.ts
#
# new('igrea') %>%
#   ticker('igrea') %>%
#   observation.start %>%
#   use.archive %>%
#   url %>%
#   download.ts%>%
#   write.ts
#
#
# new('cbr') %>%
#   ticker('export_usd') %>%
#   freq %>%
#   observation.start %>%
#   use.archive %>%
#   previous.date.till %>%
#   date.from %>%
#   cbr.ticker %>%
#   url %>%
#   download.ts %>%
#   write.ts()
#


# save info data ----
#
# variables <- data.table::fread('info/var_list.csv', encoding = 'UTF-8')
# cbr_names <- data.table::fread('info/cbr_name_list.csv', encoding = 'UTF-8')
# sources <- data.table::fread('info/source_list.csv', encoding = 'UTF-8')
# oecd_names <- data.table::fread('info/oecd_name_list.csv', encoding = 'UTF-8')
#
# usethis::use_data(variables, overwrite = TRUE)
# usethis::use_data(cbr_names, overwrite = TRUE)
# usethis::use_data(sources, overwrite = TRUE)
# usethis::use_data(oecd_names, overwrite = TRUE)

# test ----
# testthat::test_local()

# S&P 500 archive data ----
#
# archive_SP500 <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/raw/fred sp500.xlsx')[1:4132,] %>%
#   mutate(date = as.Date(date),
#          update_date = lubridate::today()) %>%
#   rename(value = sp500)
# usethis::use_data(archive_SP500, internal = TRUE, overwrite = TRUE)
# eval(parse(text = 'macroparsing:::archive_SP500'))
