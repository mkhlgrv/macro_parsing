
ticker <- function(object, ticker){
  UseMethod('ticker')
}
observation.start <- function(object){
  UseMethod('observation.start')
}
date.from <- function(object){
  UseMethod('date.from')
}
previous.date.till <- function(object){
  UseMethod('previous.date.till')
}
date.till <- function(object){
  UseMethod('date.till')
}

url <- function(object){
  UseMethod('url')
}

download.ts.chunk <- function(object){
  UseMethod('download.ts.chunk')
}
download.ts <- function(object){
  UseMethod('download.ts')
}

write.ts <- function(object){
  UseMethod('write.ts')
}