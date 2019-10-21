library(dplyr)
mtcars %>% writexl::write_xlsx() %>% shell.exec()
