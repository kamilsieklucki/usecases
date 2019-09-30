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

# summarise_if ----
summarise_if(df, nchar(names(df)) == 2, mean)

cols <- names(dt)[nchar(names(dt)) == 2]
dt[, lapply(.SD, mean),
   .SDcols = cols]

# mutate_all ----
mutate_all(df, as.integer)

dt[, lapply(.SD, as.integer)]

# analogicznie reszta przypadków

# arrange ----
df <- df %>% arrange(cyl)

setkey(dt, cyl)
setindex(dt, cyl)

setorder(dt, mpg)

# In data.table, set*() functions modify objects by reference, making these operations fast and memory-efficient. In case this is not a desired behaviour, users can use copy(). The corresponding expressions in dplyr will be less memory-efficient.

# set(*) ----
# rename ----
setnames(dt, old = "mpg", new = "test")
setnames(dt, old = "test", new = "mpg")

# reorder ----
setcolorder(dt, c("carb", "wt", "disp"))

# Advanced
# Get row number of first (and last) observation by group ----
dt[, .I[c(1, .N)], by = cyl]

# suma + poziom wyżej ----
dt[,
   .(SumV2 = sum(mpg)),
   keyby = c("cyl", "gear")]

rollup(dt,
       .(SumV2 = sum(mpg)),
       by = c("cyl", "gear"))

# Read and rbind several files ----
rbindlist(lapply(c("DT.csv", "DT.csv"), fread))

# JOINS ----
x <- data.table(Id  = c("A", "B", "C", "C"),
                X1  = c(1L, 3L, 5L, 7L),
                XY  = c("x2", "x4", "x6", "x8"),
                key = "Id")

y <- data.table(Id  = c("A", "B", "B", "D"),
                Y1  = c(1L, 3L, 5L, 7L),
                XY  = c("y1", "y3", "y5", "y7"),
                key = "Id")

# left join x <- y
y[x, on = "Id"]
left_join(x, y, by = "Id")

# right join x -> y
x[y, on = "Id"]
right_join(x, y, by = "Id")

# inner join
x[y, on = "Id", nomatch = 0]
inner_join(x, y, by = "Id")

# full join
merge(x, y, all = TRUE, by = "Id")
full_join(x, y, by = "Id")

# semi_join
unique(x[y$Id, on = "Id", nomatch = 0])
semi_join(x, y, by = "Id")

# anti_join
x[!y, on = "Id"]
anti_join(x, y, by = "Id")

# Non-equi joins ----
z <- data.table(ID = "C", Z1 = 5:9, Z2 = paste0("z", 5:9))

x[z, on = .(Id == ID, X1 <= Z1)]

