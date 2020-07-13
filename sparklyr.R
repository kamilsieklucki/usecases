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

# Analysis ----
# The sparklyr package aids in using the “push compute, collect results” principle. Most of its functions are wrappers on top of Spark API calls.
# This allows us to take advantage of Spark’s analysis components, instead of R’s. For example, when you need to fit a linear regression model,
# instead of using R’s familiar lm() function, you would use Spark’s ml_linear_regression() function.
library(sparklyr)
library(dplyr)

sc <- spark_connect(master = "local", version = "2.3")

# Import ----
# When you are using Spark, the data is imported into Spark, not R
cars <- copy_to(sc, mtcars)
# Note: When using real clusters, you should use copy_to() to transfer only small tables from R;
# large data transfers should be performed with specialized data transfer tools.

# Wrangle ----
# 1. dplyr ----
summarise_all(cars, mean) # summarise(mtcars, across(everything(), mean))

summarize_all(cars, mean) %>%
  show_query()

cars %>%
  mutate(transmission = if_else(am == 0, "automatic", "manual")) %>%
  group_by(transmission) %>%
  summarise_all(mean)

# 2. Built-in Functions ----
# Spark SQL is based on Hive’s SQL conventions and functions, and it is possible to call all these functions using dplyr as well.
summarise(cars, mpg_percentile = percentile(mpg, 0.25))
# Przykładowo Spark nie rozpozna funkcji quanitle, bo pochodzi z base: summarise(cars, mpg_percentile = quantile(mpg, 0.25))

# There is no percentile() function in R, so dplyr passes that portion of the code as-is to the resulting SQL query
summarise(cars, mpg_percentile = percentile(mpg, 0.25)) %>%
  show_query()

# To pass multiple values to percentile(), we can call another Hive function called array()
summarise(cars, mpg_percentile = percentile(mpg, array(0.25, 0.5, 0.75)))
# The output from Spark is an array variable, which is imported into R as a list variable column

# You can use the explode() function to separate Spark’s array value results into their own record.
summarise(cars, mpg_percentile = percentile(mpg, array(0.25, 0.5, 0.75))) %>%
  mutate(mpg_percentile = explode(mpg_percentile))

# A very common exploration technique is to calculate and visualize correlation
ml_corr(cars)

# The corrr R package specializes in correlations. It contains friendly functions to prepare and visualize the results.
# Included inside the package is a backend for Spark, so when a Spark object is used in corrr, the actual computation also happens in Spark.
# In the background, the correlate() function runs sparklyr::ml_corr(), so there is no need to collect any data into R prior to running the command:
library(corrr)
correlate(cars, use = "pairwise.complete.obs", method = "pearson") 

# shave() function turns all of the duplicated results into NAs
# Again, while this feels like standard R code using existing R packages, Spark is being used under the hood to perform the correlation.
correlate(cars, use = "pairwise.complete.obs", method = "pearson") %>%
  shave() %>%
  rplot()

# Visualize ----
# In essence, the approach for visualizing is the same as in wrangling: push the computation to Spark, and then collect the results in R for plotting.
library(ggplot2)
ggplot(aes(as.factor(cyl), mpg), data = mtcars) + geom_col()

# With Spark transform data and visualise in R
car_group <- cars %>%
  group_by(cyl) %>%
  summarise(mpg = sum(mpg, na.rm = TRUE)) %>%
  collect() %>%
  print()

ggplot(aes(as.factor(cyl), mpg), data = car_group) + 
  geom_col(fill = "#999999") + coord_flip()

# Now, to ease this transformation step before visualizing, the dbplot package provides a few ready-to-use visualizations that automate aggregation in Spark.
# The dbplot package provides helper functions for plotting with remote data. 
library(dbplot)

cars %>%
  dbplot_histogram(mpg, binwidth = 3) +
  labs(title = "MPG Distribution",
       subtitle = "Histogram over miles per gallon")

# scatterplot - potrzebne są wszystkie punkty bez przekształceń, więc najlepiej znaleźć alternatywę przy dużym zbiorze danych
ggplot(aes(mpg, wt), data = mtcars) + 
  geom_point()

# You can use dbplot_raster() to create a scatter-like plot in Spark, while only retrieving (collecting) a small subset of the remote dataset:
dbplot_raster(cars, mpg, wt, resolution = 16)

# Model ----
cars %>% 
  ml_linear_regression(mpg ~ .) %>%
  summary()

cars %>% 
  ml_linear_regression(mpg ~ hp + cyl) %>%
  summary()

cars %>% 
  ml_generalized_linear_regression(mpg ~ hp + cyl) %>%
  summary()

# Usually, before fitting a model you would need to use multiple dplyr transformations to get it ready to be consumed by a model.
# To make sure the model can be fitted as efficiently as possible, you should cache your dataset before fitting it, as described next.
# Caching ----
# Before fitting the models, it is a good idea to save the results of all the transformations in a new table loaded in Spark memory.
# The compute() command can take the end of a dplyr command and save the results to Spark memory.
cached_cars <- cars %>% 
  mutate(cyl = paste0("cyl_", cyl)) %>%
  compute("cached_cars")

cached_cars %>%
  ml_linear_regression(mpg ~ .) %>%
  summary()

spark_disconnect(sc)

# Communicate ----
# It is important to clearly communicate the analysis results—as important as the analysis work itself!
# The public, colleagues, or stakeholders need to understand what you found out and how.
# Można użyć RMarkdown, przykład w skrypcie sparklyr_Rmarkdown_example.Rmd
rmarkdown::render("sparklyr_Rmarkdown_example.Rmd")

# While doing analysis in Spark with R, remember to push computation to Spark and focus on collecting results in R. ----
# This paradigm should set up a successful approach to data manipulation, visualization and communication through sharing your results in a variety of outputs.


