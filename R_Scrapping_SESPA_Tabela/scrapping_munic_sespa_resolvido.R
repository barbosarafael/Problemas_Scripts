require(RSelenium)
require(tidyverse)
require(XML)
require(httr)
require(rvest)
require(lubridate)

#--- Thanks to:
# https://stackoverflow.com/questions/55201226/session-not-created-this-version-of-chromedriver-only-supports-chrome-version-7/55201365


rD <- RSelenium::rsDriver(browser = "chrome",
                          chromever =
                            system2(command = "wmic",
                                    args = 'datafile where name="C:\\\\Program Files (x86)\\\\Google\\\\Chrome\\\\Application\\\\chrome.exe" get Version /value',
                                    stdout = TRUE,
                                    stderr = TRUE) %>%
                            stringr::str_extract(pattern = "(?<=Version=)\\d+\\.\\d+\\.\\d+\\.") %>%
                            magrittr::extract(!is.na(.)) %>%
                            stringr::str_replace_all(pattern = "\\.",
                                                     replacement = "\\\\.") %>%
                            paste0("^",  .) %>%
                            stringr::str_subset(string =
                                                  binman::list_versions(appname = "chromedriver") %>%
                                                  dplyr::last()) %>%
                          as.numeric_version() %>%
                            max() %>%
                            as.character())


remote_driver <- rD[["client"]]
remote_driver$open()



#--- Endere?o para o browser acessar

remote_driver$navigate("https://www.covid-19.pa.gov.br/#/")


#--- Selecionando a url
html <- remote_driver$getPageSource()[[1]]



#--- Lendo em html
doc <- htmlParse(html)
tabelas <- readHTMLTable(doc)

dia = day(Sys.Date())
mes = month(Sys.Date())
ano = year(Sys.Date())


tabelas[[2]] %>%
  `colnames<-` (c("municipio", "confirmados", "obitos", "letalidade")) %>%
  select(municipio, confirmados, obitos) %>%
  mutate(confirmados = as.numeric(paste(confirmados)),
         obitos = as.numeric(paste(obitos)),
         letalidade = round(x = obitos/confirmados*100, digits = 2)) %>%
  write.csv(x = ., file = paste0("R_Scrapping_SESPA_Tabela/Casos_Acumulados_por_Municipio", dia, mes, ano, ".csv"))
