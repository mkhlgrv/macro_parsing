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
#   previous.date.till %>%
#   date.from %>%
#   download.ts %>%
#   write.ts
#
# new('fred') %>%
#   ticker('SP500') %>%
#   freq %>%
#   observation.start %>%
#   previous.date.till %>%
#   date.from %>%
#   download.ts%>%
#   write.ts
#
#
# new('oecd') %>%
#   ticker('cli_RUS') %>%
#   observation.start %>%
#   oecd.ticker %>%
#   url %>%
#   download.ts%>%
#   write.ts
#
# new('igrea') %>%
#   ticker('igrea') %>%
#   observation.start %>%
#   url %>%
#   download.ts%>%
#   write.ts
#
#
# new('cbr') %>%
#   ticker('export_usd') %>%
#   freq %>%
#   observation.start %>%
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
# usethis::use_data(variables, variables)
# usethis::use_data(cbr_names, cbr_names)
# usethis::use_data(sources, sources)
# usethis::use_data(oecd_names, oecd_names)

# test ----
# testthat::test_local()

