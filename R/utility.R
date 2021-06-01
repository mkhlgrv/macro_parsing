check.raw.files <- function(){
  list_files <- list.files('data/raw')
  data.table::fread('data/info/var_list.csv',
                    encoding = 'UTF-8',
                    select = 'ticker') %>%
    .$ticker %>%
    paste0('.csv') %>%
    .[which(!.%in% list_files)] %>%
    purrr::walk(function(filei){
      data.table::fwrite(tibble(date = character(),
                                value = numeric(),
                                update_date = character()),
                         file = paste0('data/raw/',
                                       filei))
    })
}  
