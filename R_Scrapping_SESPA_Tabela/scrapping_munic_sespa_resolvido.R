require(RSelenium)
require(tidyverse)
require(XML)
require(httr)
require(rvest)

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



#--- Endereço para o browser acessar

remote_driver$navigate("https://www.covid-19.pa.gov.br/#/")


#--- Selecionando a url
html <- remote_driver$getPageSource()[[1]]



#--- Lendo em html
doc <- htmlParse(html)
tabelas <- readHTMLTable(doc)


tabelas[[2]] %>%
  `colnames<-` (c("Município", "Confirmados", "Óbitos", "Letalidade")) %>%
  select(Município, Confirmados, Óbitos) %>%
  mutate(Confirmados = as.numeric(paste(Confirmados)),
         Óbitos = as.numeric(paste(Óbitos)),
         Letalidade = round(x = Óbitos/Confirmados*100, digits = 2)) %>%
  xlsx::write.xlsx(x = ., file = "Casos acumulados por municipio.xlsx")
