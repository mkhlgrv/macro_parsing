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
      previous.date.till %>%
      date.from %>%
      download.ts

  expect_s4_class(fred_ts, 'fred')
  expect_equal(fred_ts@ticker,"NBRUBIS")
  expect_equal(fred_ts@observation_start,as.Date('1997-05-20'))
  expect_equal(ncol(fred_ts@ts),3)
  expect_equal(fred_ts@ts$date %>% class,'Date')
  expect_equal(fred_ts@ts$value %>% class,'numeric')
  expect_equal(fred_ts@ts$update_date %>% class,'Date')

})
