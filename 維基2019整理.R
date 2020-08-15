rm(list = ls());gc()

library(tidyverse)
library(data.table)
library(lubridate)
setwd("C:/Users/Eric/Downloads/wiki2019")

Files = list.files()
wiki_df = data.frame()
for(i in 1:length(Files)){
  dt = fread(Files[i],data.table = F,encoding = 'UTF-8')
  cols = colnames(dt)
  parse_text = ''
  for(ix in 2:ncol(dt)){
    parse_text = paste0(parse_text,',`', cols[ix],'`')
  }
  eval(parse(text = paste0("temp = gather(data = dt, key = 'pageName', value = 'viewNums'",parse_text,')')))
  temp$Date = ymd(temp$Date)
  data_temp = temp

  wiki_df = wiki_df %>% rbind(data_temp)  
  print(paste(i ,'/',length(Files)))
}
setwd("C:/Users/Eric/Desktop/MiaoLingProject/Selenium/WIKI_to2019")
Companies = fread('wikiPageNew2019.csv',data.table = F)

wiki_df_filtered = wiki_df %>% filter(pageName%in%Companies$wiki.page)

setwd("C:/Users/Eric/Downloads/維基MS")
Files = list.files()
wiki_df_MS = data.frame()
for(i in 1:length(Files)){
  dt = fread(Files[i],data.table = F,encoding = 'UTF-8')
  cols = colnames(dt)
  parse_text = ''
  for(ix in 2:ncol(dt)){
    parse_text = paste0(parse_text,',`', cols[ix],'`')
  }
  eval(parse(text = paste0("temp = gather(data = dt, key = 'pageName', value = 'viewNums'",parse_text,')')))
  temp$Date = ymd(temp$Date)
  data_temp = temp
  
  wiki_df_MS = wiki_df_MS %>% rbind(data_temp)  
  print(paste(i ,'/',length(Files)))
}
setwd("C:/Users/Eric/Desktop/MiaoLingProject/Selenium/WIKI_to2019")
Companies_MS = fread('wikiPageNew2019MS.csv',data.table = F,encoding = 'UTF-8')
wiki_df_MS_filtered = wiki_df_MS %>% filter(pageName%in%Companies_MS$wiki.page)
Companies_pt1 = Companies[which(Companies$wiki.page%in%unique(wiki_df$pageName)),] 
Companies_pt2 = Companies_MS[which(Companies_MS$wiki.page%in%unique(wiki_df_MS$pageName)),] 

All_companies = Companies_pt1 %>% rbind(Companies_pt2)


wiki2019 = wiki_df_filtered %>%
  rbind(wiki_df_MS_filtered) %>%
  group_by(Date,pageName) %>% slice(1) %>% 
  group_by(pageName) %>% arrange(Date) %>%
  dplyr::mutate(Cum = cumsum(viewNums)) %>% 
  filter(Cum!=0) %>% select(-Cum)


wiki2019_final = wiki2019 %>% left_join(All_companies,by = c('pageName'='wiki.page')) %>% 
  select(-Trading.Symbol) %>% 
  rename('wiki.page' = 'pageName')

write.csv(wiki2019_final,'Wiki_20150701_to_20191231.csv',row.names = F)

for(i in 2015:2019){
  write.csv(wiki2019_final[which(substr(wiki2019_final$Date,1,4)==as.character(i)),],
            paste0('Wiki_',as.character(i),'.csv'),row.names = F)
}
