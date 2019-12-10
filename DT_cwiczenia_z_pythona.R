library(data.table)

path <- "~/Python/nycflights13/"
files <- c("airports", "airlines", "weather", "planes", "flights")
for(i in files){
  assign(i, fread(paste0(path, i, ".csv"))[,-c("V1")])
}

setnames(airlines, old = colnames(airlines), new = as.character(airlines[1]))
airlines <- airlines[-1]

# zad 11.4
planes[, unique(.SD), .SDcols = c("engine")]

# zad 11.5
planes[, unique(.SD), .SDcols = c("type", "engine")]

# zad 11.6
planes[, .N, by = c("engine")]

# zad 11.7
planes[, .N, by = c("engine", "type")]

# zad 11.8
planes[, .(min = min(year, na.rm = TRUE), max = max(year, na.rm = TRUE)), by = c("engine", "type")]

# zad 11.9
planes[!is.na(speed), head(.SD[, .(tailnum, speed)], 4)]

# zad 11.10
planes[year >= 2010, .(tailnum)]

# zad 11.11
planes[between(seats, 100, 200), head(.SD, 5)]

# zad 11.12
planes[
  seats >= 379 & manufacturer %in% c("BOEING", "AIRBUS"),
  head(.SD, 5),
  .SDcols = c("tailnum", "manufacturer", "seats")
]

# zad 11.13
planes[
  seats > 200,
  .(ile = .N),
  by = "manufacturer"
]

# zad 11.14
planes[
  seats > 200,
  .(ile = .N),
  by = "manufacturer"
][ile > 10]

# zad 11.15
planes[, .N, by = "manufacturer"][order(N, decreasing = TRUE)[1:3]]

# zad 11.16
planes[year < 1970, .(tailnum, year, seats)][order(year, seats)]

# zad 11.17
A <- planes[year < 1960, .(tailnum, year, type, manufacturer)]
B <- planes[year >= 1959 & year <= 1963, .(tailnum, year, type, manufacturer)]
print(A)
print(B)
funion(A, B, all = TRUE)

# zad 11.18
funion(A, B, all = FALSE)

# zad 11.19
fintersect(A, B)

# zad 11.20
fsetdiff(A, B)

# zad 11.21
flights_planes <- planes[flights, on = "tailnum"]
flights_planes2 <- merge(flights, planes, by = "tailnum", all.x = TRUE)

# update by reference join ----------------------------------------------------------------------------------------------------------
# 1: one column
flights[planes, on = 'tailnum', manufacturer := i.manufacturer] 

# 2: many columns write by hand
cols <- colnames(planes)[3:4]
flights[planes, on = 'tailnum', (cols) := .(i.type, i.manufacturer)] 

# 3: many columns choose by character vector
# https://stackoverflow.com/questions/28889057/update-a-column-of-nas-in-one-data-table-with-the-value-from-a-column-in-another
cols <- colnames(planes)[3:4]
flights[, (cols) := planes[.SD, ..cols, on = "tailnum"]]
# flights[, (cols) := planes[.SD, .(manufacturer, type), on = "tailnum"]]
# -----------------------------------------------------------------------------------------------------------------------------------

# zad 11.22
flights_airports <- airports[flights, on = c("faa" = "dest")]

# zad 11.23
flights_weather <- weather[flights, on = .(origin, year, month, day, hour)]

# zad 11.24
flights_all <- airports[
  planes[
    weather[
      flights,
      on = .(origin, year, month, day, hour)
    ], on = "tailnum"
  ], on = c("faa" = "dest")
]

