# Jeżeli któraś z wybranych kolumn jest niepusta, to zostawiamy cały wiersz
# W przeciwnym wypadku go usuwamy

DF <- data.frame(
  Indeks = c(1, 2, NA, 4, NA, rep(NA, 100000), 100006),
  EAN = rep(NA, 100006),
  Bloz = c(NA, NA, 3, NA, NA, rep(NA, 100001)),
  Bazyl = rep(NA, 100006),
  `Rabat producenta` = rep(NA, 100006),
  Ilość  = rep(NA, 100006),
  stringsAsFactors = FALSE
)

test <- function(DF, cols){
  x <- logical(nrow(DF))
  
  for (i in 1:nrow(DF)){
    print(i)
    if (any(!is.na(DF[i,cols]))) x[i] <- TRUE
  }
  
  return(DF[x,])
}


cols <- c("Indeks", "EAN", "Bloz", "Bazyl")

system.time(
  test(DF, cols)
)

system.time(
  DF %>% filter_at(vars(Indeks:Bazyl), any_vars(!is.na(.)))
)
            