
# list.files('C:/Users/mkhlgrv/Documents/forecast/database/raw')
# lf = list.files('C:/Users/mkhlgrv/Documents/macroparsing_usage/data/raw', full.names = TRUE)
# lf_names = list.files('C:/Users/mkhlgrv/Documents/macroparsing_usage/data/raw', full.names = FALSE)
#
# rio::import('C:/Users/mkhlgrv/Documents/forecast/database/raw/gdp_nom.xlsx')
# rio::import('C:/Users/mkhlgrv/Documents/macroparsing_usage/data/raw/gdp_nom.csv')
#
# x = purrr::map_dfr(1:length(lf), function(i){
#   obs_start = lf[i] %>% rio::import() %>% summarise(x=min(date)) %>% pull(x) %>% as.character
#   tick = gsub('.csv', '',lf_names[i])
#   tibble(observation_start = obs_start, ticker = tick)
# })
# obs= x %>% arrange(ticker) %>% .[,"observation_start"]
#
# vals = rio::import('C:/Users/mkhlgrv/Documents/macroparsing/info/var_list.csv',
#             encoding='UTF-8') %>% arrange(ticker)
# vals$observation_start = obs %>%
#   pull(observation_start)
# vals %>% rio::export(file = 'C:/Users/mkhlgrv/Documents/macroparsing/info/var_list.csv')
#
#
#
# archive data ----
# # S&P 500
# archive_SP500 <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/raw/fred sp500.xlsx')[1:4132,] %>%
#   mutate(date = as.Date(date),
#          update_date = lubridate::today()) %>%
#   rename(value = sp500)
# # eval(parse(text = 'macroparsing:::archive_SP500'))
# # usd
# archive_usd <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded d.xlsx')[,c('date',"usd")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2001-04-03') %>%
#     rename(value = usd) %>%
#   na.omit
#
# # cons_nom
# archive_cons_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"cons_nom")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = cons_nom) %>%
#   na.omit
#
#
# # export_nom
# archive_export_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"export_nom")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = export_nom) %>%
#   na.omit
#
#
# # import_nom
# archive_import_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"import_nom")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = import_nom) %>%
#   na.omit
#
# # invest_fixed_capital_nom
# archive_invest_fixed_capital_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"invest_fixed_capital_nom")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = invest_fixed_capital_nom) %>%
#   na.omit
#
#
# # invest_nom
# archive_invest_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"invest_nom")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = invest_nom) %>%
#   na.omit
#
# # labor_income_nom
#
# archive_labor_income_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"labor_income_nom")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = labor_income_nom) %>%
#   na.omit
#
# # gross_profit_nom
# archive_gross_profit_nom <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"gross_profit_nom")] %>%
#   mutate(date = as.Date(date),
#          update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#   rename(value = gross_profit_nom) %>%
#   na.omit
#
# # cons_real
# archive_cons_real <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"cons_real")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = cons_real) %>%
#   na.omit
#
#
# # export_real
# archive_export_real <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"export_real")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = export_real) %>%
#   na.omit
#
#
# # import_real
# archive_import_real <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"import_real")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = import_real) %>%
#   na.omit
#
# # invest_fixed_capital_real
# archive_invest_fixed_capital_real <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"invest_fixed_capital_real")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = invest_fixed_capital_real) %>%
#   na.omit
#
#
# # invest_real
# archive_invest_real <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded q.xlsx')[,c('date',"invest_real")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2011-01-01') %>%
#     rename(value = invest_real) %>%
#   na.omit
#
# # ipi
# archive_ipi <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded m.xlsx')[,c('date',"mpi")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2015-01-01') %>%
#     rename(value = mpi) %>%
#   na.omit
# # ppi
# archive_ppi <- rio::import('C:/Users/mkhlgrv/Documents/forecast/database/binded/binded m.xlsx')[,c('date',"ppi")] %>%
#     mutate(date = as.Date(date),
#            update_date = lubridate::today()) %>%
#   filter(date < '2016-01-01') %>%
#     rename(value = ppi) %>%
#   na.omit
# # money_income
# archive_money_income = data.table::fread('C:/Users/mkhlgrv/Documents/macroparsing/info/archive/money_income_1996.csv',
#                                          colClasses = c("Date", "numeric", "Date")) %>% na.omit
# # income_real
# archive_income_real = data.table::fread('C:/Users/mkhlgrv/Documents/macroparsing/info/archive/income_real_1996.csv',
#                                         colClasses = c("Date", "numeric", "Date")) %>% na.omit
# # # income_real_disp
# archive_income_real_disp = data.table::fread('C:/Users/mkhlgrv/Documents/macroparsing/info/archive/income_real_disp_1996.csv',
#                                              colClasses = c("Date", "numeric", "Date")) %>% na.omit
# # # employed
# archive_employed = data.table::fread('C:/Users/mkhlgrv/Documents/macroparsing/info/archive/employed_15_72.csv',
#                                      colClasses = c("Date", "numeric", "Date"))[1:216,] %>% na.omit
# # # unemployed
# archive_unemployed = data.table::fread('C:/Users/mkhlgrv/Documents/macroparsing/info/archive/unemployed_15_72.csv',
#                                        colClasses = c("Date", "numeric", "Date"))[1:216,] %>% na.omit
# # # unemployment
# archive_unemployment = data.table::fread('C:/Users/mkhlgrv/Documents/macroparsing/info/archive/unemployment_15_72.csv',
#                                          colClasses = c("Date", "numeric", "Date"))[1:216,] %>% na.omit
# # # writing ----
# # # важно: только один файл с внутренней информацией
# usethis::use_data(archive_SP500,
#                   archive_usd,
#                   archive_cons_nom,
#                   archive_export_nom,
#                   archive_import_nom,
#                   archive_invest_fixed_capital_nom,
#                   archive_invest_nom,
#                   archive_labor_income_nom,
#                   archive_gross_profit_nom,
#                   archive_cons_real,
#                   archive_export_real,
#                   archive_import_real,
#                   archive_invest_fixed_capital_real,
#                   archive_invest_real,
#                   archive_ipi,
#                   archive_ppi,
#                   archive_money_income,
#                   archive_income_real,
#                   archive_income_real_disp,
#                   archive_employed,
#                   archive_unemployed,
#                   archive_unemployment,
#                   internal = TRUE, overwrite = TRUE)
