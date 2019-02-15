library(padr)
library(dplyr)
library(lubridate)
library(janitor)

df <- data.frame(
  stringsAsFactors=FALSE,
  date = c("2019-02-13", "2019-02-07", "2019-02-11", "2019-02-13",
           "2019-02-01", "2019-02-02", "2019-02-03", "2019-02-04"),
  index = c(1, 2, 2, 2, 3, 3, 3, 3),
  index_name = c("x", "y", "y", "y", "z", "z", "z", "z"),
  attr1 = c(0, 0, 0, 0, 0, 0, 0, 0),
  attr2 = c(0, 0, 0, 0, 0, 0, 0, 0),
  measure1 = c(1, 1, 1, 3, 20, 17, 3, 107),
  measure2 = c(1, 0, 0, 0, 3, 1, 0, 13),
  measure3 = c("100,0%", "0,0%", "0,0%", "0,0%", "15,0%", "5,9%", "0,0%", "12,1%")
)

df <- janitor::clean_names(df)

df %>% 
  mutate_at(vars(date), lubridate::ymd) %>% 
  pad(interval = "day",
      start_val = ymd(min(df$date)),
      end_val = ymd(max(df$date)),
      by = "date",
      group = c("index", "index_name", "attr1", "attr2")) %>% 
  fill_by_value() %>% 
  View()

