test_that("Test cbr methods", {
  cbr_ts <- new('cbr') %>%
    ticker('fer') %>%
    freq %>%
    observation.start %>%
    previous.date.till %>%
    date.from %>%
    cbr.ticker %>%
    url %>%
    download.ts()
  expect_match(cbr_ts@url,
               'https://www.cbr.ru/eng/hd_base/mrrf/mrrf_7d/')
  expect_s4_class(cbr_ts, 'cbr')
  expect_equal(cbr_ts@ticker,"fer")
  expect_equal(cbr_ts@cbr_ticker,"mrrf/mrrf_7d")
  expect_equal(cbr_ts@observation_start,as.Date('1998-05-29'))
  expect_equal(ncol(cbr_ts@ts),3)

})

test_that("Test fred methods", {
  fred_ts <-  new('fred') %>%
      ticker('NBRUBIS') %>%
      freq %>%
      observation.start %>%
      use.archive %>%
      previous.date.till %>%
      date.from %>%
      download.ts

  expect_s4_class(fred_ts, 'fred')
  expect_equal(fred_ts@ticker,"NBRUBIS")
  expect_equal(fred_ts@observation_start,as.Date('1997-05-20'))
  expect_equal(ncol(fred_ts@ts),3)
  expect_equal(fred_ts@use_archive,FALSE)
  expect_equal(fred_ts@ts$date %>% class,'Date')
  expect_equal(fred_ts@ts$value %>% class,'numeric')
  expect_equal(fred_ts@ts$update_date %>% class,'Date')

})



test_that("Test oecd methods", {
  oecd_ts <- new('oecd') %>%
    ticker('cli_RUS') %>%
    observation.start %>%
    oecd.ticker %>%
    url %>%
    download.ts

  expect_s4_class(oecd_ts, 'oecd')
  expect_equal(oecd_ts@ticker,"cli_RUS")
  expect_match(oecd_ts@url, 'org/sdmx-json/data/MEI_CLI/LOLITOAA')
  expect_equal(oecd_ts@observation_start,as.Date('1992-09-01'))
  expect_equal(ncol(oecd_ts@ts),3)
  expect_equal(oecd_ts@ts$date %>% class,'Date')
  expect_equal(oecd_ts@ts$value %>% class,'numeric')
  expect_equal(oecd_ts@ts$update_date %>% class,'Date')

})


test_that("Test IGREA methods", {
  igrea_ts <- new('igrea') %>%
      ticker('igrea') %>%
      observation.start %>%
      url %>%
      download.ts

  expect_s4_class(igrea_ts, 'igrea')
  expect_equal(igrea_ts@ticker,"igrea")
  expect_match(igrea_ts@url, 'media/Documents/research/igrea/igrea')
  expect_equal(igrea_ts@observation_start,as.Date('1968-01-01'))
  expect_equal(ncol(igrea_ts@ts),3)
  expect_equal(igrea_ts@ts$date %>% class,'Date')
  expect_equal(igrea_ts@ts$value %>% class,'numeric')
  expect_equal(igrea_ts@ts$update_date %>% class,'Date')

})

test_that("Test moex methods", {

  moex_ts <- new('moex') %>%
    ticker('IMOEX') %>%
    observation.start %>%
    use.archive %>%
    previous.date.till %>%
    date.from %>%
    download.ts
  expect_s4_class(moex_ts, 'moex')
  expect_equal(moex_ts@ticker,"IMOEX")
  expect_equal(moex_ts@observation_start,
               as.Date('1997-09-22'))
  expect_equal(ncol(moex_ts@ts),3)

})
