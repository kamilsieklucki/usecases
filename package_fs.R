library(fs)
library(readxl)

pliki <- dir_ls(glob = "*.xlsx")

dane <- purrr::map(enc2native(pliki), readxl::read_excel)
