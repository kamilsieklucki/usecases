# https://rpubs.com/xiaodai/intro-disk-frame

# devtools::install_github("xiaodaigh/disk.frame")

library(nycflights13)
library(dplyr)
library(disk.frame)

# convert the flights data to a disk.frame and store the disk.frame in the folder
# "tmp_flights" and overwrite any content if needed
flights.df <- as.disk.frame(
  flights, 
  outdir = "tmp_flights", 
  overwrite = T)
flights.df


# write a csv
data.table::fwrite(nycflights13::flights, "tmp_flights.csv")

# load the csv into a disk.frame
flights.df <- csv_to_disk.frame(
  "tmp_flights.csv", 
  outdir = "tmp_flights.df",
  overwrite = T)

flights.df


# If the CSV is too large to read in, then we can also use the in_chunk_size option to control how many rows to read in at once.
# For example to read in the data 100,000 rows at a time.
library(nycflights13)
library(disk.frame)

# write a csv
data.table::fwrite(flights, "tmp_flights.csv")

flights.df <- csv_to_disk.frame(
  "tmp_flights.csv", 
  outdir = "tmp_flights_too_large.df",
  in_chunk_size = 100000)

flights.df

# disk.frame also has a function zip_to_disk.frame that can convert every CSV in a zip file to disk.frames.


flights.df1 <- select(flights.df, year:day, arr_delay, dep_delay)
flights.df1
class(flights.df1)

# Pobranie danych z plików tymczasowych
x <- collect(flights.df1)

filter(flights.df, dep_delay > 1000) %>% collect

mutate(flights.df, speed = distance / air_time * 60) %>% collect

# this only sorts within each chunk
arrange(flights.df, dplyr::desc(dep_delay)) %>% collect

# Similarly summarise creates summary variables within each chunk and hence also needs to be used with caution.
# In the Group By section, we demonstrate how to use summarise in the disk.frame context correctly with hard group_bys.
summarise(flights.df, mean_dep_delay = mean(dep_delay, na.rm =T)) %>% collect

# get the first two rows of each chunk
do(flights.df, head(., 2)) %>% select(year:day, arr_delay, dep_delay) %>% collect


# List of supported dplyr verbs ----
# 
# select
# rename
# filter
# arrange # within each chunk
# group_by # with hard = T options
# summarise/summarize # within each chunk
# mutate
# transmute
# left_join
# inner_join
# full_join # careful. Performance!
# semi_join
# anit_join

# The disk.frame implements the group_by operation with a significant caveat. In the disk.frame framework,
# group-by requires the user to specify hard = TRUE or FALSE. To group by hard = TRUE means that all rows with the same group
# keys will end up in the same file chunk. However, the hard group_by operation can be VERY TIME CONSUMING computationally and
# should be avoided if possible.
flights.df %>%
  group_by(carrier, hard = T) %>% # notice that hard = T needs to be set
  summarize(count = n(), mean_dep_delay = mean(dep_delay, na.rm=T)) %>%  # mean follows normal R rules
  collect

# One can restrict which input columns to load into memory for each chunk; this can significantly increase the speed of data processing.
# To restrict the input columns, use the srckeep function which only accepts column names as a string vector.
flights.df %>%
  srckeep(c("carrier","dep_delay")) %>%
  group_by(carrier, hard = T) %>% # notice that hard = T needs to be set
  summarize(count = n(), mean_dep_delay = mean(dep_delay, na.rm=T)) %>%  # mean follows normal R rules
  collect

# make airlines a data.table
airlines.dt <- setDT(copy(airlines))
# flights %>% left_join(airlines, by = "carrier") #
flights.df %>% left_join(airlines.dt) %>% collect

flights.df %>% left_join(airlines.dt, by = c("carrier", "carrier")) %>% collect

# Find the most and least delayed flight each day
bestworst <- flights.df %>%
  srckeep(c("year","month","day", "dep_delay")) %>%
  group_by(year, month, day, hard = TRUE) %>%
  select(dep_delay) %>%
  filter(dep_delay == min(dep_delay, na.rm = T) || dep_delay == max(dep_delay, na.rm = T)) %>%
  collect

bestworst

# Rank each flight within a daily
ranked <- flights.df %>%
  srckeep(c("year","month","day", "dep_delay")) %>%
  group_by(year, month, day, hard = T) %>%
  select(dep_delay) %>%
  mutate(rank = rank(desc(dep_delay))) %>%
  collect

ranked

# One can apply arbitrary transformations to each chunk of the disk.frame by using the delayed function which evaluates lazily or the
# map.disk.frame(lazy = F) function which evaluates eagerly. For example to return the number of rows in each chunk
flights.df1 <- delayed(flights.df, ~nrow(.x))
collect_list(flights.df1)

map.disk.frame(flights.df, ~nrow(.x), lazy = F)

# The map.disk.frame function can also output the results to another disk.frame folder, e.g.
# return the first 10 rows of each chunk
flights.df2 <- map.disk.frame(flights.df, ~.x[1:10,], lazy = F, outdir = "tmp2", overwrite = T)

flights.df2
# Notice disk.frame supports the purrr syntax for defining a function using ~.

# Sampling
flights.df %>% sample_frac(0.01) %>% collect



# One can output a disk.frame by using the write_disk.frame function. E.g.
write_disk.frame(flights.df, outdir="out")
# this will output a disk.frame to the folder “out”