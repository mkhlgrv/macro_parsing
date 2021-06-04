check.raw.files <- function(){
  list_files <- list.files(system.file("inst/extdata/raw",
                                       package = "macroparsing"))
  data.table::fread(system.file("data/info/var_list.csv", package = "macroparsing"),
                    encoding = 'UTF-8',
                    select = 'ticker') %>%
    .$ticker %>%
    paste0(".csv") %>%
    .[which(!.%in% list_files)] %>%
    purrr::walk(function(filei){
      data.table::fwrite(tibble(date = character(),
                                value = numeric(),
                                update_date = character()),
                         file = system.file(paste0("data/raw/",
                                       filei),
                                       package = "macroparsing"))
    })
}
