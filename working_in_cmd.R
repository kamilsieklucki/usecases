args <- commandArgs(trailingOnly = TRUE)
fn <- args[1]

if (is.null(fn) || is.na(fn)) stop("Podaj argument = liczba wierszy do wyswietlenia")

dane <- mtcars[1:fn,]
print(dane)
