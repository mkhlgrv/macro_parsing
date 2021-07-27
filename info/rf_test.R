library(caret)
library(dplyr)
out <- {x <- list.files('C:/Users/mkhlgrv/Documents/macroparsing_usage/data/deseason/', full.names = TRUE)[22:55]
  names(x) <- list.files('C:/Users/mkhlgrv/Documents/macroparsing_usage/data/deseason/')[22:55]
  x} %>%
  purrr::imap_dfr(function(i, iname){

  data.table::fread(i) %>%
      dplyr::mutate(date = zoo::as.Date(zoo::as.yearqtr(date))) %>%
      dplyr::group_by(date) %>%
      dplyr::filter(row_number()==max(row_number())) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(variable = gsub('.csv', '', iname)) %>%
      dplyr::select(date,variable,value)

}) %>%
  dplyr::filter(!variable %in% c('depo', 'repo', 'monetary_base_weekly', 'mosprime', 'sadlo', 'RGBITR', 'RGBI')) %>%
  reshape2::dcast(data = .,date~variable)

out$export_usd[209:210] <- 0
X.matrix<- model.matrix(export_usd~0+., out %>%
                          select(-c(date, import_usd)))
out$export_usd[209:210] <- NA
y.vector <- out$export_usd[144:210]
# out$import_usd[209:210] <- 0
# X.matrix<- model.matrix(import_usd~0+., out %>%
#                select(-c(date, export_usd)))
# out$import_usd[209:210] <- NA

dates <- seq.Date(from = as.Date('2004-10-01'), by = '3 month', length.out = 67)
tc <- trainControl(method = 'oob')

set.seed(1)
params <- expand.grid(ntree = c(500,1000,5000),
                      nodesize = c(3,4,5,6,7),
                      nPerm = c(1,2),
                      corr.bias=c(TRUE,FALSE),
                      preProc = c('no'),
                      i=41:61,

                      stringsAsFactors = FALSE)


models <- params %>%
  split(seq_along(1:nrow(.))) %>%
  purrr::map(function(params){

    X.train <- X.matrix[1:(params$i-1),]

    y.train <- y.vector[1:(params$i-1)]
    X.test <- X.matrix[params$i:67,]
    y.test <- y.vector[params$i:67]


    #create tunegrid
    if(params$preProc=='pca'){
      mtry_default <- 6
    } else {
      mtry_default <- round(ncol(X.train)/3)
    }
    if(params$preProc=='no'){
      prepro <- NULL
    } else{
      prepro <- params$preProc
    }

    tune_grid <- expand.grid(.mtry = seq((mtry_default-5),
                                         (mtry_default+5)))

    fit <- train(x = X.train,
                 y = y.train,
                 method = "rf",
                 metric = "RMSE",
                 tuneGrid = tune_grid,
                 trControl = tc,
                 ntree = params$ntree,
                 nodesize = params$nodesize,
                 preProcess = prepro,
                 replace = TRUE,
                 nPerm=params$nPerm,
                 corr.bias = params$corr.bias
    )

    cbind(params,
          date = dates[params$i],
          true=y.test[1],
          predict =  predict(fit,newdata = X.test) %>% as.numeric %>% .[1])

  })

save(models, file='info/rf_model.RDa')
load('info/rf_model.RDa')

res <- models %>%
  purrr::map_dfr(function(x){x})

res %>%
  # filter(date < '2020-01-01') %>%
  filter(preProc=='no',
         corr.bias == TRUE,
         nPerm==2,
         # nodesize==7,
         ntree == 5000,
        ) %>%
  mutate(ntree = as.factor(ntree),
         nPerm = as.factor(nPerm),
         nodesize = as.factor(nodesize)) %>%
  select(-true) %>%
  inner_join(tibble(true=y.vector, date = dates), by='date') %>%
  mutate(error = true-predict) %>%
  ggplot(aes(x = date))+
  # geom_point()+
  # geom_line()+
  geom_line(aes(y=abs(error)^2, color=nodesize))+
  geom_point(aes(y=abs(error)^2, color=nodesize))+
  # group_by(ntree, nodesize, nPerm, corr.bias, preProc) %>%
  # summarise(rmse = mean(error^2)) %>% View
  # ggplot(aes(x = ntree, y = rmse, color = corr.bias))+
  # geom_point()+
  facet_wrap(.~+corr.bias)

# models[[1]]
#
#
#
# dates <- seq.Date(from = as.Date('2004-10-01'), by = '3 month', length.out = 67)
# comp <- prcomp(X.matrix) %>% .$x %>% .[,1]
# ggplot(mapping = aes(x=dates, y= comp))+
#   geom_point()+
#   geom_line()#+
#   geom_line(aes(y = pred, color='pred'))+
#   geom_line(aes(y = pred2, color='pred2'))+
#   geom_line(aes(y = pred3, color='pred3'))
#
# fit3
