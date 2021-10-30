# Clear test .temp directory
files <- list.files(".temp",
                    full.names = TRUE,
                    recursive = TRUE)

for(file in files){
  file.remove(file)
}
unlink("/.temp",recursive = TRUE)

test_that("Test downloading in temp directory", {

  Sys.setenv("directory"="/.temp")

  download(tickers=c("gdp_real","import_real"),
           sources = c("dallasfed"))

  # expect_s4_class(dallasfed_ts, 'dallasfed')
  expect_equal(dir.exists(paths = c("/.temp/data/log",
                          "/.temp/data/raw",
                          "/.temp/data/tf",
                          "/.temp/data/raw_excel")),rep(TRUE,4))

})
