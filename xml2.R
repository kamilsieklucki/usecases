library(tidyverse)
library(readxl)
library(xml2)
library(dplyr)

# library(XML)
# 
# x <- xmlParse("~/../Desktop/ASY00050022.xml")
# df <- xmlToDataFrame(node = getNodeSet(x, "//ASY/SUBSTYTUCJE"))

asy0 <- read_xml("~/../Desktop/ASY00050022.xml")

# nagłowek
name <- xml_name(asy0)

# cała struktura
root <- xml2::xml_root(asy0)

# dzieci w strukturze
child <- xml_children(asy0)

# cały tekst
text <- xml_text(asy0)


substytucje <- asy0 %>%
  xml_find_all("//SUBSTYTUCJA") %>%
  as_list() %>%
  tibble(s = .) %>%
  unnest_wider(s) %>%
  unnest_wider(KLUCZ) %>%
  unnest() %>%
  unnest()

substytycje2 <- substytucje %>%
  mutate(
    MATERIAL = as.integer(MATERIAL),
    INDEKS = as.integer(INDEKS),
    DATA_OD = as.Date(DATA_OD, "%Y.%m.%d"),
    DATA_DO = as.Date(DATA_DO, "%Y.%m.%d")
  )

