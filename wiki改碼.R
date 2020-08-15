rm(list = ls());gc()
setwd("C:/Users/Eric/Desktop/MiaoLingProject/Selenium/WIKI_to2019")

library(tidyverse)
library(data.table)

Pages.1 = readxl::read_xlsx('CompanyData_new.xlsx')
Pages.2 = fread('wikiPage_company_all.csv',data.table = F)[,c(1,4,2)] %>% 
  rename(Company.Name = 'COMNAM', wiki.page = 'WIKIaft2015',Trading.Symbol = 'TICKER')



Pages = Pages.1 %>%
  rbind(Pages.2) %>%
  filter(!is.na(wiki.page)) %>%
  group_by(Company.Name) %>%
  slice(1)
Pages$wiki.page = gsub('_',' ',Pages$wiki.page)
Pages$wiki.page = gsub('%28','(',Pages$wiki.page)
Pages$wiki.page = gsub('%29',')',Pages$wiki.page)
Pages$wiki.page = gsub('%23','#',Pages$wiki.page)
Pages$wiki.page = gsub('%26','&',Pages$wiki.page)
Pages$wiki.page = gsub('%2C',',',Pages$wiki.page)
Pages$wiki.page = gsub('%27',"'",Pages$wiki.page)
Pages$wiki.page = gsub('%20',' ',Pages$wiki.page)
Pages$wiki.page = gsub('%2B','+',Pages$wiki.page)
Pages$wiki.page = gsub('%21','!',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%A9','',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%B3','o',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%AB','e',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%A3','a',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%AD','i',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%A8','e',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%B1','n',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%89','E',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%AC','i',Pages$wiki.page)
Pages$wiki.page = gsub('%C3%BA','u',Pages$wiki.page)
Pages$wiki.page = gsub('%2F','/',Pages$wiki.page)
Pages$wiki.page = gsub('%E2%80%93','–',Pages$wiki.page)


write.csv(Pages,'wikiPageNew2019.csv',row.names = F)
