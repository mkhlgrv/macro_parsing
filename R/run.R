# library(dplyr)
# # library(data.table)
# # library(future)
# # library(purrr)
# # plan(multisession)
# # MOEX
#
# check.files()
#
# new('moex') %>%download.by.ticker('IMOEX')
#
# new('fred') %>%download.by.ticker('SP500')
#
# new('oecd') %>%download.by.ticker('cli_RUS')
#
# new('dallasfed') %>%download.by.ticker('igrea')
#
# new('cbr') %>%download.by.ticker('export_usd')

# save info data ----

# variables <- data.table::fread('info/var_list.csv', encoding = 'UTF-8')
# cbr_names <- data.table::fread('info/cbr_name_list.csv', encoding = 'UTF-8')
# sources <- data.table::fread('info/source_list.csv', encoding = 'UTF-8')
# oecd_names <- data.table::fread('info/oecd_name_list.csv', encoding = 'UTF-8')
#
# usethis::use_data(variables, overwrite = TRUE)
# usethis::use_data(cbr_names, overwrite = TRUE)
# usethis::use_data(sources, overwrite = TRUE)
# usethis::use_data(oecd_names, overwrite = TRUE)

#
# rosstat_tables <- data.table::fread('info/rosstat_table_list.csv', encoding = 'UTF-8')
# rosstat_table_patterns <- data.table::fread('info/rosstat_table_pattern_list.csv', encoding = 'UTF-8')
# rosstat_ticker_tables <- data.table::fread('info/rosstat_ticker_table_list.csv', encoding = 'UTF-8')
# rosstat_headers <- data.table::fread('info/rosstat_header_list.csv', encoding = 'UTF-8')
#
#
# usethis::use_data(rosstat_tables, overwrite = TRUE)
# usethis::use_data(rosstat_table_patterns, overwrite = TRUE)
# usethis::use_data(rosstat_ticker_tables, overwrite = TRUE)
# usethis::use_data(rosstat_headers, overwrite = TRUE)


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


# # download all data ----
# library(macroparsing)
# check.files()
# st <- Sys.time()
# download(source='cbr', use_future = F)
# Sys.time() - st
# do.call(file.remove,
#         list(list.files("C:/Users/mkhlgrv/Documents/macroparsing_usage/data/raw/",
#                         full.names = TRUE)))
# check.files()
# st <- Sys.time()
# download(source='cbr', use_future = TRUE)
# Sys.time() - st
# download(sources = 'moex')
# macroparsing::download(ticker ='cli_RUS')
# download(ticker='SP500')
# devtools::load_all()
# options(java.parameters = "- Xmx1024m")

# список всех функций (NCmisc)
# rfile <- file.choose() # choose an R script file with functions
# NCmisc::list.functions.in.file(rfile)

# usethis::use_package("dplyr")
# usethis::use_package("data.table")
# usethis::use_package("XML")
# usethis::use_package("plyr")
# usethis::use_package("fredr")
# usethis::use_package("zoo")
# usethis::use_package("httr")
# usethis::use_package("purrr")
# usethis::use_package("readxl")
# usethis::use_package("tibble")
# usethis::use_package("lubridate")
# usethis::use_package("jsonlite")
# usethis::use_package("stringr")
# usethis::use_package("furrr")
# usethis::use_package("future")


# roxygen2::roxygenise()


# devtools::build()
# devtools::install_local(path = 'macroparsing_0.0.0.9000.tar.gz', dependencies = TRUE,force=TRUE)

# shiny::runApp('app/macroparsing')
