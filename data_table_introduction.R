library(data.table)

input <- if (file.exists("flights14.csv")) {
  "flights14.csv"
} else {
  "https://raw.githubusercontent.com/Rdatatable/data.table/master/vignettes/flights14.csv"
}
flights <- fread(input)

str(flights)

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
