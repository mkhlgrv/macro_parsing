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
# rosstat_xls_patterns <- data.table::fread('info/rosstat_xls_pattern_list.csv', encoding = 'UTF-8')
# rosstat_ticker_tables <- data.table::fread('info/rosstat_ticker_table_list.csv', encoding = 'UTF-8')
# rosstat_headers <- data.table::fread('info/rosstat_header_list.csv', encoding = 'UTF-8')
# internal_tickers <- data.table::fread('info/internal_ticker_list.csv', encoding = 'UTF-8')
# additional_info <- data.table::fread('info/var_list_additional.csv', encoding = 'UTF-8')
#
#
# usethis::use_data(rosstat_tables, overwrite = TRUE)
# usethis::use_data(rosstat_table_patterns, overwrite = TRUE)
# usethis::use_data(rosstat_xls_patterns, overwrite = TRUE)
# usethis::use_data(rosstat_ticker_tables, overwrite = TRUE)
# usethis::use_data(rosstat_headers, overwrite = TRUE)
# usethis::use_data(internal_tickers, overwrite = TRUE)
# usethis::use_data(additional_info, overwrite = TRUE)

# # test ----
# testthat::test_local()


# # download all data ----
# library(rmedb)
# check.files()
# st <- Sys.time()
# download(source='cbr', use_future = F)
# Sys.time() - st
# do.call(file.remove,
#         list(list.files("C:/Users/mkhlgrv/Documents/rmedb_usage/data/raw/",
#                         full.names = TRUE)))
# check.files()
# st <- Sys.time()
# download(source='cbr', use_future = TRUE)
# Sys.time() - st
# download(sources = 'moex')
# rmedb::download(ticker ='cli_RUS')
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
#
#
# devtools::build()
# devtools::install_local(path = "C:/Users/migareev/Documents/rmedb_0.0.0.9002.tar.gz")#, dependencies = TRUE,force=TRUE)
# update.log.file()

# Sys.setenv("directory"="tests/temp")
# Sys.setenv("log_file"="tests/temp/current_log.log")

### для теста

#
# input <- list(c("source"="rosstat", "ticker"="gdp_real"),
#               c("source"="moex", "ticker"="RGBITR"),
#               c("source"="fff", "ticker"="hf"))
#
#
#
# # purrr::walk(input, process.by.ticker, download=TRUE, transform=TRUE)
#
# process.by.table("gdp_income")
# TODO mosprime перестал обновляться
# TODO li_retail перестал обновляться
# services_real не обновляется почему то

