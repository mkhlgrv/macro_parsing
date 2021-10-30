find.by.pattern <- function(x, pattern){
  if(length(pattern)>0){
    x <- stringr::str_match(string = x,
                            pattern[[1]])[1,2]
    pattern <- pattern[-1]
    find.by.pattern(x, pattern)
  } else {
    x
  }
}


get.next.weekday <- function(date, day, lead=0){
  library(lubridate)
  date <- as.Date(date)
  out <- Date()
  for(i in 1:length(date)){
    dates <- seq(date[i]+ 7*(lead), date[i] + 7*(lead+1) - 1, by="days")
    out[i] <- dates[lubridate::wday(dates, label=T)==day]
  }
  out
}




check.bracket <- function(x){
  if(!is.numeric(x)){
    x <- gsub(' ','' ,x)
    x <- gsub('\\d{1}\\)','' ,x)
    x <- gsub(',','\\.' ,x)

  }
  x
}
