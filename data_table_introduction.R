library(data.table)

input <- if (file.exists("flights14.csv")) {
  "flights14.csv"
} else {
  "https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv"
}
flights <- fread(input)

str(flights)
# PART 1--------------------------------------------------------------
# subset logical
ans <- flights[origin == "JFK" & month == 6L]
# subset position
ans <- flights[1:2]
# sort
ans <- flights[order(origin, -dest)]
# choose columns as vector
ans <- flights[, arr_delay]
# choose columns as data.table - As long as j-expression returns a list, each element of the list will be converted to a column in the resulting data.table. 
ans <- flights[, list(arr_delay)]
ans <- flights[, .(arr_delay)] # the same with dot alias
ans <- flights[, .(arr_delay, dep_delay)]
ans <- flights[, .(delay_arr = arr_delay, delay_dep = dep_delay)]
# Compute or do in j
ans <- flights[, sum( (arr_delay + dep_delay) < 0 )]
# Subset in i and do in j
ans <- flights[origin == "JFK" & month == 6L,
               .(m_arr = mean(arr_delay), m_dep = mean(dep_delay))]
ans <- flights[origin == "JFK" & month == 6L, length(dest)]
ans <- flights[origin == "JFK" & month == 6L, .N] # the same using .N a special built-in variable that holds the number of observations in the current group.
# how can I refer to columns by names in j (like in a data.frame)?
ans <- flights[, c("arr_delay", "dep_delay")]
select_cols <- c("arr_delay", "dep_delay")
flights[ , ..select_cols] # preffered form
flights[ , select_cols, with = FALSE] # disallowing j to handle expressions
# deselect cols
ans <- flights[, !c("arr_delay", "dep_delay")]
ans <- flights[, -c("arr_delay", "dep_delay")]
# select / deselect with :
ans <- flights[, year:day]
ans <- flights[, day:year]
ans <- flights[, -(year:day)]
ans <- flights[, !(year:day)]
# Grouping using by - grouping variables are not sorted
ans <- flights[, .(.N), by = .(origin)]
ans <- flights[, .(.N), by = "origin"]
ans <- flights[, .N, by = origin] # because there is one variable
ans <- flights[carrier == "AA", .N, by = origin]
ans <- flights[carrier == "AA", .N, by = .(origin, dest)]
ans <- flights[carrier == "AA", .N, by = c("origin", "dest")]
ans <- flights[carrier == "AA",
               .(mean(arr_delay), mean(dep_delay)),
               by = .(origin, dest, month)]
# Grouping using by - grouping variables are sorted
ans <- flights[carrier == "AA",
               .(mean(arr_delay), mean(dep_delay)),
               keyby = .(origin, dest, month)]
# Chaining
ans <- flights[carrier == "AA", .N, by = .(origin, dest)][order(origin, -dest)]
# Expressions in by
ans <- flights[, .N, .(dep_delay>0, arr_delay>0)]
# Multiple columns in j - .SD
# data.table provides a special symbol, called .SD. It stands for Subset of Data. It by itself is a data.table that holds the data for the current group defined using by.
# specify just the columns we would like to compute on using the argument .SDcols. It accepts either column names or column indices.
ans <- flights[carrier == "AA",                       ## Only on trips with carrier "AA"
               lapply(.SD, mean),                     ## compute the mean
               by = .(origin, dest, month),           ## for every 'origin,dest,month'
               .SDcols = c("arr_delay", "dep_delay")] ## for just those specified in .SDcols

# Subset .SD for each group:
# – How can we return the first two rows for each month?
ans <- flights[, head(.SD, 2), by = month]

DT = data.table(
  ID = c("b","b","b","a","a","c"),
  a = 1:6,
  b = 7:12,
  c = 13:18
)
# – How can we concatenate columns a and b for each group in ID?
DT[, .(val = c(a,b)), by = ID]
# – What if we would like to have all the values of column a and b concatenated, but returned as a list column?
DT[, .(val = list(c(a,b))), by = ID]

# PART 2--------------------------------------------------------------
# Add columns by reference
flights[, `:=`(speed = distance / (air_time/60), # speed in mph (mi/h)
               delay = arr_delay + dep_delay)]   # delay in minutes
head(flights)
flights[, c("speed", "delay") := list(distance/(air_time/60), arr_delay + dep_delay)] # lub tak
# Update some rows of columns by reference - sub-assign by reference
flights[hour == 24L, hour := 0L][] # [] na końcu wyświetla wynik na konsoli
# Delete column by reference
flights[, c("delay") := NULL]
flights[, `:=`(delay = NULL)]
# := along with grouping using by
flights[, max_speed := max(speed), by = .(origin, dest)] # ala mutate na group_by
# Multiple columns and :=
in_cols  = c("dep_delay", "arr_delay")
out_cols = c("max_dep_delay", "max_arr_delay")
flights[, c(out_cols) := lapply(.SD, max), by = month, .SDcols = in_cols]
# RHS gets automatically recycled to length of LHS - multiple delete cols
flights[, c("speed", "max_speed", "max_dep_delay", "max_arr_delay") := NULL]
head(flights)
# := and copy() ----
# := for its side effect
foo <- function(DT) {
  DT[, speed := distance / (air_time/60)] # add speed to table
  DT[, .(max_speed = max(speed)), by = month] # return result max speed per month
}
ans = foo(flights)
head(flights)
ans
flights[, speed := NULL] # delete
# The copy() function
# we wouldn’t want to update the original object. We can accomplish this using the function copy().
# The copy() function deep copies the input object and therefore any subsequent update by reference operations performed on the copied object will not affect the original object.
foo <- function(DT) {
  DT <- copy(DT)                              ## deep copy
  DT[, speed := distance / (air_time/60)]     ## doesn't affect 'flights'
  DT[, .(max_speed = max(speed)), by = month]
} # jw ale nie zmienia bazowej ramki danych
ans <- foo(flights)
head(flights)
head(ans)
# przykład z copy i nazwami kolumn
DT = data.table(x = 1L, y = 2L)
DT_n = names(DT)
DT_n
## add a new column by reference
DT[, z := 3L]
## DT_n also gets updated
DT_n
## use `copy()`
DT_n = copy(names(DT))
DT[, w := 4L]
## DT_n doesn't get updated
DT_n

# PART 3--------------------------------------------------------------
# Set, get and use keys on a data.table
setkey(flights, origin)
setkeyv(flights, "origin") # useful to program with
# You can also set keys directly when creating data.tables using the data.table() function using key argument. It takes a character vector of column names.
# Once you key a data.table by certain columns, you can subset by querying those key columns using the .() notation in i. Recall that .() is an alias to list().
flights[.("JFK")]
flights[J("JFK")]
flights[list("JFK")]
flights["JFK"] # dla pojedynczej
flights[c("JFK", "LGA")]
flights[.(c("JFK", "LGA"))]
# How can we get the column(s) a data.table is keyed by?
key(flights)
# Keys and multiple columns
setkey(flights, origin, dest)
setkeyv(flights, c("origin", "dest"))
key(flights)
# Subset all rows using key columns where first key column origin matches “JFK” and second key column dest matches “MIA”
flights[.("JFK", "MIA")]
# Subset all rows where just the first key column origin matches “JFK”
flights[.("JFK")]
# Subset all rows where just the second key column dest matches “MIA”
flights[.(unique(origin), "MIA")] # We can not skip the values of key columns before. Therefore we provide all unique values from key column origin.
# Select in j
flights[.("LGA", "TPA"), .(arr_delay)]
flights[.("LGA", "TPA"), "arr_delay", with = FALSE]
# Chaining
flights[.("LGA", "TPA"), .(arr_delay)][order(-arr_delay)]
# Compute or do in j
flights[.("LGA", "TPA"), max(arr_delay)]
# sub-assign by reference using := in j
flights[, sort(unique(hour))]
setkey(flights, hour)
key(flights)
flights[.(24), hour := 0L]
key(flights)
flights[, sort(unique(hour))]
# Aggregation using by
setkey(flights, origin, dest)
key(flights)
ans <- flights["JFK", max(dep_delay), keyby = month]
head(ans)
key(ans)
# The mult argument - We can choose, for each query, if “all” the matching rows should be returned, or just the “first” or “last” using the mult argument.
flights[.("JFK", "MIA"), mult = "first"]
flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last"]
# COMMENT: Once again, the query for second key column dest, “XNA”, is recycled to fit the length of the query for first key column origin, which is of length 3.
# The nomatch argument - We can choose if queries that do not match should return NA or be skipped altogether using the nomatch argument.
flights[.(c("LGA", "JFK", "EWR"), "XNA"), mult = "last", nomatch = NULL]
# binary search vs vector scans - pierwsza metoda jest dużo szybsza i jest używana nawet, gdy stosujemy standardowe filtrowanie dlatego trzeba wyczyścić klucz jeżeli chcemy je stosować
# key by origin,dest columns
flights[.("JFK", "MIA")]
flights[origin == "JFK" & dest == "MIA"]
setkey(flights, NULL)
flights[origin == "JFK" & dest == "MIA"]
# COMMENT: warto przeczytać tą część teorytyczną, aby wiedzieć jak to działa !!!