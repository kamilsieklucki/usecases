library(DBI)
library(dplyr)
library(dbplyr)

#tworzenie połączenia do HD
con <- DBI::dbConnect(odbc::odbc(), dsn = "DataMart.ad.firm.pl", uid = "user", database = "DataMart")

#lista tabel na połączeniu
tab <- DBI::dbListTables(con) %>% tibble()

#lista kolumn na wybranym połączeniu i tabeli
col <- DBI::dbListFields(con, "table1") %>% tibble()

#wygenerowanie zapytania SQL na połączeniu
data <- DBI::dbGetQuery(con, "SELECT *
FROM table1 pw where id =7")

#utworzenie wirtualnej tabeli, która odwołuje się do tabeli w HD
pw <- tbl(con, "table1")

#można na niej wykonywać różne operacje
pw_id <- pw %>% filter(id %in% c(7))

#podgląd zapytania w SQL
show_query(pw_id)

#pobranie danych do R, można przypisać do zmiennej
collect(pw_id) 

#rozłączenie połączenia z tabelą
dbDisconnect(con)
