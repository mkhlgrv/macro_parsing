# archive <- list()
# for(i in list.files('info/archive/')){
#   name_i <- gsub('.csv', "", i)
#   archive[[name_i]] <- data.table::fread(file = paste0('info/archive/',i),
#                                          colClasses = c("Date","numeric","Date"))
#
# }
# usethis::use_data(archive, internal = TRUE, overwrite = TRUE)
