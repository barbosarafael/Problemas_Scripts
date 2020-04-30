library(tidyverse)
library(httr)
library(rvest)


url <- "https://www.covid-19.pa.gov.br/#/"


#--- Aqui eu recebo a mensagem:

#{xml_missing}
#<NA>

url %>%
  httr::GET() %>%
  httr::content("text", encoding = "UTF-8") %>%
  xml2::read_html() %>%
  rvest::html_node('table')

#---------------------------------------------

#--- Aqui eu recebo a mensagem:

#{xml_missing}
#<NA>

url %>%
  xml2::read_html() %>%
  rvest::html_node(xpath = '//*[@id="q-app"]/div/div/div/div[1]/div/main/div[4]/div[2]/div/div/div[3]/div/div[2]/div/div/table')


#---------------------------------------------

#--- Aqui eu recebo a mensagem:

#{xml_nodeset (0)}

url %>%
  xml2::read_html() %>%
  html_nodes("table")


#---------------------------------------------

#--- Aqui foi um simples que tentei fazer com o site da curso-r e bateu legal

"https://www.curso-r.com/blog/2019-09-10-rbrasil/" %>%
  xml2::read_html() %>%
  rvest::html_nodes(xpath = '//*[@id="importando-os-dados"]/table') %>%
  html_table()




"C:\\Users\\Rafael\\Downloads\\Monitoramento COVID-19.html" %>%
  xml2::read_html() %>%
  rvest::html_nodes(xpath = '//*[@id="q-app"]/div/div/div/div[1]/div/main/div[4]/div[2]/div/div/div[3]/div/div[2]/div/div/table') %>%
  html_table()
