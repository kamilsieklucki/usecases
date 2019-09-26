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

