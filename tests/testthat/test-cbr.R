setwd('C:/Users/Mikhail Gareev/Documents/macroparsing')
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
