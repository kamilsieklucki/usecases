# Wymagania: ----
# 1. Java w wersji 8, sprawdzenie system("java -version")
# 2. Instalacja pakietu install.packages("sparklyr")
# 3. Instalacja sparka w konkretnej wersji spark_install("2.3")
# 4. Zainstalowane wersje sparka spark_installed_versions()

# Połączenie spark ----
library(sparklyr)
sc <- spark_connect(master = "local", version = "2.3")

# Kopia danych do sparka, a właściwie -> copy_to() returns a reference to the dataset in Spark ----
cars <- copy_to(sc, mtcars)

cars

# Podgląd komend na konsoli sparka w przeglądarce ----
spark_web(sc)

# When using Spark from R to analyze data, you can use SQL (Structured Query Language) or dplyr (a grammar of data manipulation). ----
library(DBI)
dbGetQuery(sc, "SELECT count(*) FROM mtcars")

library(dplyr)
count(cars)

# In general, we usually start by analyzing data in Spark with dplyr, followed by sampling rows and selecting a subset of the available columns.----
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

# zapis do csv ----
spark_write_csv(cars, "cars.csv")

# odczyt z csv ----
cars <- spark_read_csv(sc, "cars.csv")

