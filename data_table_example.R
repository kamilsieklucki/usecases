# https://atrebas.github.io/post/2019-03-03-datatable-dplyr/
library(data.table)
library(dplyr)

# tworzenie data table ----
DT <- data.table::as.data.table(ggplot2::diamonds)
class(DT)
DT

DF <- ggplot2::diamonds
class(DF)
DF

# filtrowanie wg numeru wiersz ----
DT[3:6]
DF %>% slice(3:6)

DT[!1:3]
DF %>% slice(-(1:3))

# filtrowanie wg warunku logicznego ----
DT[cut == "Good"]
DF %>% dplyr::filter(cut == "Good")

# %chin% działa szybko dla tekstu ale cut to factor więc liczba
DT[cut %in% c("Good", "Very Good") & color == "J"]
DF %>% dplyr::filter(cut %in% c("Good", "Very Good"), color == "J")  

# liczenie unikatów i sortowanie
unique(DT)
unique(DT, by = c("cut","color")) # zostają wszystkie kolumny
unique(DT[, .(cut,color)])[order(cut, -color)] # zostają wybrane kolumny


distinct(DF)
distinct_at(DF, vars("cut","color")) %>% arrange(cut, desc(color))

# wybór kolumn .() oznacza listę
DT[, .(cut, color)]
DT[, !c("cut", "color")]

DF %>% select(cut, color)
DF %>% select(-cut, -color)

# agregacja danych
