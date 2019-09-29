#### https://atrebas.github.io/post/2019-03-03-datatable-dplyr/ ####

library(dplyr)
library(data.table)

df <- mtcars
dt <- as.data.table(mtcars)

# Slice ----
df %>% slice(5:7)

dt[5:7]
dt[5:7, ]

df %>% slice(-(1:2))

dt[!1:2]
dt[-(1:2), ]

# Filter ----
df %>% filter(mpg > 20, cyl == 4)

dt[mpg > 20 & cyl == 4]

# Distinct ----
df %>% distinct()
df %>% distinct_at(vars(cyl, gear))

unique(dt)
unique(dt, by = c("cyl", "gear")) # zostają wszystkie kolumny więc to nie jest efekt, który był zamierzony
unique(dt[, .(cyl, gear)])

# Sort ----
df %>% arrange(desc(mpg), disp)

dt[order(-mpg, disp)]

# Select ----
df %>% select(mpg, cyl)
df %>% select(-(mpg:cyl))

dt[, .(mpg, cyl)]
dt[, c("mpg", "cyl")]
dt[, !c("mpg", "cyl")]
dt[, -c("mpg", "cyl")]
# usuwanie zmiennej całkowicie ze zbioru danych
dt[, c("mpg", "cyl") := NULL]

x <- c("mpg", "cyl")

df %>% select(!!x)
df %>% select(-!!x)

dt[, ..x]
dt[, !..x]
dt[, -..x]
# usuwanie zmiennej całkowicie ze zbioru danych
dt[, (x) := NULL]

# Summarise ----
df %>% summarise(suma_mpg = sum(mpg), srednia_mpg = mean(mpg))

dt[, .(suma_mpg = sum(mpg), srednia_mpg = mean(mpg))]

# Mutate ----
# DT - modyfikuje w miejscu nie trzeba przypisywać do nowej zmiennej, aby otrzymać rezultat
df2 <- df %>% mutate(cyl_2 = cyl ^ 2, sqrt_disp = sqrt(disp))
df2

dt[, ':='(cyl_2 = cyl^2,  sqrt_disp = sqrt(disp))]
dt[, c("cyl_2", "sqrt_disp") := .(cyl^2, sqrt(disp))]
dt

# Transmute ----
df %>% transmute(cyl_2 = cyl ^ 2)

dt[, .(cyl_2 = cyl ^ 2)]

# Change values in column ----
df %>% mutate(cyl = replace(cyl, cyl == 4, 0L))

dt[cyl == 4, cyl := 0L]

# group by ----
df %>% group_by(cyl, gear) %>% summarise(suma = sum(disp))

dt[, .(suma = sum(disp)), keyby = .(cyl, gear)] # lub by -> The sole difference between by and keyby is that keyby orders the results and creates a key that will allow faster subsetting

# count ----
df %>% count(cyl)

dt[, .N, keyby = cyl]

# add_count ----
df %>% add_count(cyl)

dt[, n := .N, by = cyl]

# To further manipulate columns, dplyr includes nine functions: the _all, _at, and _if versions of summarise(), mutate(), and transmute().
# With data.table, we use .SD, which is a data.table containing the Subset of Data for each group, excluding the column(s) used in by. So, DT[, .SD] is DT itself and in the expression DT[, .SD, by = V4], .SD contains all the DT columns (except V4) for each values in V4 (see DT[, print(.SD), by = V4]). .SDcols allows to select the columns included in .SD.
# summarise_all ----
df %>% summarise_all(max)

dt[, lapply(.SD, max)]

# summarise_at ----
df %>% group_by(am) %>% summarise_at(vars(cyl, gear), list(min, max))

dt[, c(lapply(.SD, min), lapply(.SD, max)), .SDcols = c("cyl", "gear"), keyby = am]





