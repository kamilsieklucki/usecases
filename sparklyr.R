# Wymagania: ----
# 1. Java w wersji 8, sprawdzenie system("java -version")
# 2. Instalacja pakietu install.packages("sparklyr")
# 3. Instalacja sparka w konkretnej wersji spark_install("2.3")
# 4. Zainstalowane wersje sparka spark_installed_versions()

# Connecting spark ----
library(sparklyr)
sc <- spark_connect(master = "local", version = "2.3")

# Using Spark  ----
# Kopia danych do sparka, a właściwie -> copy_to() returns a reference to the dataset in Spark
cars <- copy_to(sc, mtcars)

cars

# Web Interface ----
# Podgląd komend na konsoli sparka w przeglądarce
spark_web(sc)

# Analysis ----
# When using Spark from R to analyze data, you can use SQL (Structured Query Language) or dplyr (a grammar of data manipulation).
library(DBI)
dbGetQuery(sc, "SELECT count(*) FROM mtcars")

library(dplyr)
count(cars)

# Modeling ----
# In general, we usually start by analyzing data in Spark with dplyr, followed by sampling rows and selecting a subset of the available columns.
# The last step is to collect data from Spark to perform further data processing in R, like data visualization.
cars %>% 
  select(hp, mpg) %>%
  sample_n(100) %>% # slice_sample(n = 100) ale jeszcze nie działa :)
  collect() %>%
  plot()

model <- ml_linear_regression(cars, mpg ~ hp)
model

model %>%
  ml_predict(copy_to(sc, data.frame(hp = 250 + 10 * 1:10))) %>%
  transmute(hp = hp, mpg = prediction) %>%
  full_join(select(cars, hp, mpg)) %>%
  collect() %>%
  plot()

# Data ----
# zapis do csv
spark_write_csv(cars, "cars.csv")

# odczyt z csv
cars <- spark_read_csv(sc, "cars.csv")

# Extentions ----
# sparkly.nested extension is an R package that extends sparklyr to help you manage values that contain nested information
install.packages("sparklyr.nested")

sparklyr.nested::sdf_nest(cars, hp) %>%
  group_by(cyl) %>%
  summarise(data = collect_list(data))

# Distributed R ----
# When functionality is not available in Spark and no extension has been developed, you can consider distributing your own R code across the Spark cluster.
# This is a powerful tool, but it comes with additional complexity, so you should only use it as a last resort.
cars %>%
  spark_apply(~round(.x))

# Streaming ----
# dane które wciąż napływają; To try out streaming, let’s first create an input/ folder with some data that we will use as the input for this stream:
dir.create("input")
write.csv(mtcars, "input/cars_1.csv", row.names = F)

# Then, we define a stream that processes incoming data from the input/ folder, performs a custom transformation in R, and pushes the output into an output/ folder:
stream <- stream_read_csv(sc, "input/") %>%
  select(mpg, cyl, disp) %>%
  stream_write_csv("output/")

# Since the input contained only one file, the output folder will also contain a single file
dir("output", pattern = ".csv")

# Write more data into the stream source
write.csv(mtcars, "input/cars_2.csv", row.names = F)

# Check the contents of the stream destination
dir("output", pattern = ".csv")

# You should then stop the stream:
stream_stop(stream)

# Logs ----
# For local clusters, we can retrieve all the recent logs by running the following:
spark_log(sc)

# Or, we can retrieve specific log entries containing, say, sparklyr, by using the filter parameter, as follows:
spark_log(sc, filter = "sparklyr")

# Disconnecting ----
# For local clusters (really, any cluster), after you are done processing data, you should disconnect by running the following:
spark_disconnect(sc)

# you can also disconnect all your Spark connections by running this command:
spark_disconnect_all()