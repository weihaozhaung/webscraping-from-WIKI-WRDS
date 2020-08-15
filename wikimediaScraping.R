
rm(list=ls());gc()

# 使用函數包
library(rvest)
library(tidyverse)
library(R.utils)
library(urltools)
library(xlsx)
library(foreach)
library(doSNOW)
library(data.table)

setwd("C:/Users/Eric/Desktop/MiaoLingProject/wiki_data/wiki_downloads")
wikiCompanyList <- fread('wikiPage_company_zip.csv', data.table = F ,encoding = 'UTF-8')
setwd("E:/2013-11")

wikiCompanyList <- wikiCompanyList %>%
  as.data.frame() %>%
  rename(companyName = COMNAM,
         wikiPageName = WIKI) %>%
  select(companyName, wikiPageName) %>%
  na.omit()

Files = list.files()

targetYM = substr(Files[1],12,19)

storeTable <- NULL

cl =makeCluster(5)
registerDoSNOW(cl)
pb = txtProgressBar(max = length(Files), style = 3)
progress <- function(n) setTxtProgressBar(pb,n)
opts <- list(progress = progress)
length(Files)
storeTable <- foreach(iy = 1:length(Files),.combine = 'rbind',
                      .packages = c('tidyverse','R.utils','data.table'),.options.snow = opts)%dopar%{

  dataDate <- strsplit(Files[iy], split = "-")[[1]][2] %>% as.numeric()
  dataTime <- strsplit(Files[iy], split = "-")[[1]][3]%>% as.numeric()
  dataTime <- floor(dataTime/10000) 
  

  if(file.size(Files[iy]) != 0){
    
    data <- read.table(file = Files[iy], quote="", sep = " " , 
                       header = F, stringsAsFactors= F, fill = TRUE, skip = 2500) %>%
      as_data_frame()  %>%
      rename(language = V1, pageName = V2, viewNums = V3)
    
    keyPage <- data %>% 
      filter(language == "en") %>%
      filter(pageName %in% wikiCompanyList$wikiPageName) %>%
      group_by(pageName) %>%
      summarise(viewNums = sum(as.numeric(viewNums), na.rm = T)) %>%
      transmute(dataDate, dataTime, pageName, viewNums)
    
    storeTable <- storeTable %>% bind_rows(keyPage)
    return(storeTable)
  }else{return(NULL)}
  
}
stopCluster(cl)

storeTable <- storeTable %>%
  group_by(dataDate, pageName) %>%
  summarise(viewNums = sum(viewNums, na.rm = T))

setwd("C:/Users/Eric/Desktop/MiaoLingProject/wiki_data/wiki_downloads")

write.csv(storeTable, file = paste0(substr(targetYM,1,4),'-',substr(targetYM,5,6), "-wiki-page-view-numbers.csv"), row.names = F)


