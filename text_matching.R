library(fuzzyjoin)
library(dplyr)

lokalizacja <- "N:/Rshiny/DAIRRKDT/"

pool <- dbPool(
  drv = RSQLite::SQLite(),
  dbname = paste0(lokalizacja, "data/DAIRRKDT.db")
)

indeks <- tbl(pool, "kartoteka_t") %>% 
  collect()
  

indeks2 <- indeks %>% 
  select(id_kartoteki, nazwa) %>% 
  mutate(nazwa_skorygowana = stringr::str_squish(nazwa))

df2 <- readxl::read_excel("~/../Desktop/Merck Przejazd.xlsx")



stringdist_join(df2, indeks2, 
                by = c("NAZWA LEKU" = "nazwa_skorygowana"),
                mode = "left",
                ignore_case = FALSE, 
                method = "jw", 
                max_dist = 99, 
                distance_col = "dist"
) %>%
  group_by(`NAZWA LEKU`) %>%
  top_n(1, -dist) %>% 
  View()

# x <- df2[[1,2]]
# 
# y <- indeks %>% filter(id_kartoteki == 12123) %>% pull(nazwa) %>% stringr::str_squish()
# 
# stringdist::stringdist(x, y, method = "jw")
