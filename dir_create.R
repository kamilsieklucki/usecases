library(lubridate)
library(dplyr)

path <- "N:/SOLARIS Efektywność promocji/ZASILENIE - wspólne wszystkie rodziny/"

actual_month <- month(Sys.Date()) %>% 
  recode(`1` = "Styczeń",
         `2` = "Luty",
         `3` = "Marzec",
         `4` = "Kwiecień",
         `5` = "Maj",
         `6` = "Czerwiec",
         `7` = "Lipiec",
         `8` = "Sierpień",
         `9` = "Wrzesień",
         `10` = "Październik",
         `11` = "Listopad",
         `12` = "Grudzień") 

actual_year <- year(Sys.Date())

dir <- paste0(path, actual_month, "_", actual_year, "/")

dir.create(dir)
dir.create(paste0(dir, "ALL_FLOWS"))

list_of_files <- list.files(paste0(path, "ALL_FLOWS"), full.names=TRUE)
file.copy(list_of_files, paste0(dir, "ALL_FLOWS"))
