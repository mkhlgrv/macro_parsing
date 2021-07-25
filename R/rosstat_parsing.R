pattern <- function(object) {
  UseMethod("")
}
setMethod("pattern","rosstat",
          function(object){
            rosstat@pattern
          })
# получаем файл
url <- "https://rosstat.gov.ru/compendium/document/50802"
pattern_1 <- "Electronic edition(.*?)December 2016"
pattern_2 <- 'href=\\"(.*?)\\"'

file_url <- stringr::str_match(string = paste0(readLines(url,encoding = 'UTF-8'),
                                               collapse = ''),
                               pattern_1)[1,2] %>%
  stringr::str_match(string = .,
            pattern_2) %>%
  .[1,2]

file_url <- paste0("https://rosstat.gov.ru/",file_url)

httr::GET(file_url,#object@url,
          httr::write_disk(temp_file <-
                             tempfile(fileext = ".xlsx")))
sheet <- grep("(^1.1)( |\\.|$)", readxl::excel_sheets(temp_file))
freq_cols <- 1:6
freq_by = "1 quarter"

res <- xlsx::read.xlsx(file = temp_file, sheetName = sheet, colIndex = freq_cols, startRow = 2)
res %>% colnames()
match_n <- 1
start_row <- grep(pattern = "/ GDP, bln rubles", x = res[,1])[match_n]+1
res <- res[start_row:nrow(res),]
end_row <- (which(grepl("\\d{4}",res[,1])==FALSE)-1)[1]
start_year <- res[1,1]
start_column <- grep('I', colnames(res))[1]
value <-  res[start_row:end_row,start_column:ncol(res)] %>% t %>% as.matrix %>% as.numeric()
tibble::tibble(
  date = seq.Date(as.Date(paste0(start_year, "-01-01")), by =freq_by, length.out = length(value) ),
  value = value
)

# из скаченного файла достаем переменную
# ticker sheet_name header_pattern
# первый столбец (кварталы или месяцы) определяем по первой встрече "I" или "Jan."
#
#
# get.url.rosstat <- function(tabname = 'cpi'){
#   if(tabname == 'cpi'){
#     url <- 'https://rosstat.gov.ru/storage/mediabank/f5RJefBn/Индексы%20потребительских%20цен.html'
#     pattern <- '<a  href=\\"(.*?)\\">на  товары и услуги</a>'
#
#     file_url <- str_match(string = paste0(readLines(url),collapse = ''), pattern)[1,2]
#
#   } else if(tabname == 'ppi'){
#     url <- 'https://rosstat.gov.ru/storage/mediabank/MnPNkLA4/tab-prom-okved2.htm'
#
#
#     pattern_1 <- 'Производителей промышленных товаров(.*?)><span'
#     pattern_2 <- '<a  href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#   }else if(tabname == 'cargo_price'){
#     url <- 'https://rosstat.gov.ru/storage/mediabank/XEtSuAuM/tab-gruz1.htm'
#
#
#     pattern_1 <- '<b>Индексы тарифов на грузовые перевозки(.*?)><span'
#     pattern_2 <- '<a  href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#
#   } else if(tabname == 'mpi'){
#     url <- 'https://rosstat.gov.ru/enterprise_industrial'
#
#
#     pattern_1 <- 'базисный 2018 год(.*?)Индексы промышленного производства по субъектам Российской Федерации'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2300:2800],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   } else if(tabname == 'monthly_survey'){
#     url <- 'https://rosstat.gov.ru/leading_indicators'
#
#
#     pattern_1 <- 'title-page(.*?)Добыча полезных ископаемых'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2000:2500],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   } else if(tabname == 'unemployment'){
#     url <- 'https://rosstat.gov.ru/labour_force'
#
#
#     pattern_1 <- 'Уровень безработицы населения в возрасте 15 лет и старше по субъектам Российской Федерации(.*?)Уровень безработицы населения в возрасте 15-72 лет по субъектам Российской Федерации'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2800:3300],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   } else if(tabname == 'base_output'){
#     url <- 'https://rosstat.gov.ru/accounts'
#
#
#
#     pattern_1 <- '>Индекс выпуска товаров и услуг по базовым видам экономической деятельности<(.*?)к предыдущему периоду'
#     pattern_2 <- 'соответствующему периоду предыдущего года(.*?)в %'
#     pattern_3 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[4200:4900],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_3) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   } else if(tabname == 'building'){
#     url <- 'https://rosstat.gov.ru/leading_indicators'
#
#
#     pattern_1 <- 'Добыча(.*?)Строительство'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2200:2500],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   }else if(tabname == 'retail'){
#     url <- 'https://rosstat.gov.ru/leading_indicators'
#
#
#     pattern_1 <- 'Строительство(.*?)Розничная торговля'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2300:2600],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   } else if(tabname == 'consumer'){
#     url <- 'https://rosstat.gov.ru/leading_indicators'
#
#
#     pattern_1 <- 'Сфера услуг(.*?)Потребительский сектор'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2300:2600],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#
#   }else if(tabname == 'gdp_nom_va'){
#     url <- 'https://rosstat.gov.ru/accounts'
#
#     pattern_1 <- 'Произведенный ВВП. Квартальные данные по ОКВЭД 2(.*?)текущих ценах'
#     pattern_2 <- 'Доля малого и среднего предпринимательства в валовом внутреннем продукте(.*?)В '
#     pattern_3 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2700:3000],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_3) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   }else if(tabname == 'gdp_real_va'){
#     url <- 'https://rosstat.gov.ru/accounts'
#
#     pattern_1 <- 'Произведенный ВВП. Квартальные данные по ОКВЭД 2(.*?)В постоянных ценах с исключением сезонного фактора'
#     pattern_2 <- '</i>DOC</a>(.*?)</i>XLSX</a>'
#     pattern_3 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2700:3000],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_3) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   }else if(tabname == 'gdp_nom_expend'){
#     url <- 'https://rosstat.gov.ru/storage/mediabank/4kfiafkX/tab28.htm'
#
#     pattern <- 'href=\\"(.*?)\\">2011'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern) %>%
#       .[1,2]
#
#   }else if(tabname == 'gdp_real_expend'){
#     url <- 'https://rosstat.gov.ru/storage/mediabank/rchyXzZz/tab29.htm'
#
#     pattern <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern) %>%
#       .[1,2]
#
#   } else if(tabname == 'retail_spending'){
#     url <- 'https://rosstat.gov.ru/folder/23457'
#     pattern_1 <- 'Оборот розничной торговли, по Российской Федерации - месячный(.*?)\\.htm">'
#     pattern_2 <- '>PNG<(.*?)>XLS<'
#     pattern_3 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_3) %>%
#       .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   }else if(tabname == 'wholesale'){
#     url <- 'https://rosstat.gov.ru/folder/14306'
#     pattern_1 <- 'по Российской Федерации, оборот оптовой торговли(.*?)по Российской Федерации по месяцам'
#     pattern_2 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   }else if(tabname == 'wage_nom'){
#     url <- 'https://rosstat.gov.ru/labor_market_employment_salaries'
#     pattern_1 <- 'Среднемесячная номинальная начисленная заработная плата работников в целом по экономике Российской Федерации(.*?)по месяцам'
#     pattern_2 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#   }else if(tabname == 'employment'){
#     url <- 'https://rosstat.gov.ru/labour_force'
#
#
#     pattern_1 <- 'Численность занятых в возрасте 15 лет и старше по субъектам Российской Федерации(.*?)Численность занятых в возрасте 15-72 лет по субъектам Российской Федерации'
#     pattern_2 <- 'href=\\"(.*?)\\"'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2500:2800],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>%
#       .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#   }else if(tabname == 'gdp_income'){
#     url <- 'https://rosstat.gov.ru/storage/mediabank/0t6Ycy6V/tab35.htm'
#
#     pattern <- 'href=\\"(.*?)\\">2011'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern) %>%
#       .[1,2]
#
#   }else if(tabname == 'disp_income_real'){
#     url <- 'https://rosstat.gov.ru/folder/13397'
#
#     pattern_1 <- 'Объем и структура денежных доходов населения Российской Федерации по источникам поступления \\(новая методология\\)(.*?)Реальные располагаемые денежные доходы населения по Российской Федерации \\(новая методология\\)'
#     pattern_2 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>% .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#   }
#
#   else if(tabname == 'trp_cargo'){
#     url <- 'https://rosstat.gov.ru/folder/23455'
#
#     pattern_1 <- 'Отправление грузов водным транспортом в районы Крайнего Севера(.*?)Основные показатели перевозочной деятельности транспорта'
#     pattern_2 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8'),collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>% .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#   }else if(tabname == 'investment_nom'){
#     url <- 'https://rosstat.gov.ru/investment_nonfinancial'
#
#     pattern_1 <- 'Оперативная информация(.*?)Структура инвестиций в основной капитал'
#     pattern_2 <- 'Структура инвестиций(.*?)Инвестиции в основной капитал'
#     pattern_3 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[3000:3500],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>% .[1,2] %>%
#       str_match(string = .,
#                 pattern_3) %>% .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#   }else if(tabname == 'construction_nom'){
#     url <- 'https://rosstat.gov.ru/folder/14458'
#
#     pattern_1 <- 'Оперативная информация(.*?)выполненный по виду деятельности'
#     pattern_2 <- 'Ввод в действие мощностей и объектов социально-культурного назначения по субъектам Российской Федерации(.*?)Объем работ'
#     pattern_3 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[3000:3500],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>% .[1,2] %>%
#       str_match(string = .,
#                 pattern_3) %>% .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#   }
#
#   else if(tabname == 'retail_real'){
#     file_url <- 'http://sophist.hse.ru/hse/1/tables/RTRD_M_I.htm'
#
#
#   }else if(tabname == 'wholesale_real'){
#     url <- 'https://rosstat.gov.ru/folder/14306'
#
#     pattern_1 <- 'по Российской Федерации\\, индекс физического объема оборота оптовой торговли(.*?)по Российской Федерации по месяцам'
#     pattern_2 <- 'href=\\"(.*?)\\">'
#
#     file_url <- str_match(string = paste0(readLines(url, encoding = 'UTF-8')[2200:2600],collapse = ''),
#                           pattern_1) %>%
#       .[1,2] %>%
#       str_match(string = .,
#                 pattern_2) %>% .[1,2]
#     file_url <- paste0('https://rosstat.gov.ru',file_url)
#
#   }
#   else if(tabname == 'services'){
#     file_url <- 'https://showdata.gks.ru/finder/descriptors/276924'
#
#
#   }else if(tabname == 'investment_real'){
#     file_url <- 'http://sophist.hse.ru/hse/1/tables/INVFC_Q_I.htm'
#
#
#   }else if(tabname == 'construction_real'){
#     file_url <- 'http://sophist.hse.ru/hse/1/tables/CNSTR_M.htm'
#
#
#   }
#   else if(tabname == 'wage_real'){
#     file_url <- 'http://sophist.hse.ru/hse/1/tables/WAG_M.htm'
#
#
#   }
#   file_url
# }
#
