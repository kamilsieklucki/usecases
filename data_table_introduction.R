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
