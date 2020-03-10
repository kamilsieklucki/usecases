# https://drive.google.com/open?id=1QOmVDpd8hcVYqqUXDXf68UMDWQZP0wQV
library(data.table)

# take a look on data ----
data_sample <- fread("survey_results_public.csv", nrows = 10)

mydt <- fread("survey_results_public.csv")

# select columns ----
dt1 <- mydt[, c("LanguageWorkedWith", "LanguageDesireNextYear", 
                "OpenSourcer", "CurrencySymbol", "ConvertedComp", 
           "Hobbyist")]

dt1 <- mydt[, list(LanguageWorkedWith, LanguageDesireNextYear, 
                   OpenSourcer, CurrencySymbol, ConvertedComp, 
                   Hobbyist)]

dt1 <- mydt[, .(LanguageWorkedWith, LanguageDesireNextYear, 
                OpenSourcer, CurrencySymbol, ConvertedComp, 
                Hobbyist)]

mycols <- c("LanguageWorkedWith", "LanguageDesireNextYear", 
            "OpenSourcer", "CurrencySymbol", "ConvertedComp", "Hobbyist")
dt1 <- mydt[, ..mycols]

# count rows ----
mydt[, .N]

mydt[, .N, Hobbyist]

mydt[, .N, .(Hobbyist, OpenSourcer)]

mydt[, .N, .(Hobbyist, OpenSourcer)][order(Hobbyist, -N)]

# add columns ----
# working in-place
# Find a pattern that starts with a word boundary — the \\b, then an R,
# and then end with another word boundary. 
dt1[, PythonUser := ifelse(LanguageWorkedWith %like% "Python", TRUE, FALSE)]

dt1[, `:=`(
  PythonUser = ifelse(LanguageWorkedWith %like% "Python", TRUE, FALSE),
  RUser = ifelse(LanguageWorkedWith %like% "\\bR\\b", TRUE, FALSE)
)]

# other operators ----
# between
comp_50_100k <- dt1[CurrencySymbol == "USD" & 
                      ConvertedComp %between% c(50000, 100000)]

# character in
rareos <- dt1[OpenSourcer %chin% c("Never", "Less than once per year")]

# fcase - fcase(condition1, "value1", condition2, "value2")
# A default value for “everything else” can be added with default = value.
usd <- dt1[CurrencySymbol == "USD" & !is.na(ConvertedComp)]

usd[, Language := fcase(
  RUser & !PythonUser, "R",
  PythonUser & !RUser, "Python",
  PythonUser & RUser, "Both",
  !PythonUser & !RUser, "Neither"
)]

# .SD ----
dt1[1:5, {print(.BY); print(.SD)}, by = OpenSourcer]
