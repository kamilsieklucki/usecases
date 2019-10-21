valid <- c('tomek@drogimex.pl',
           'tomek.sochacki@drogimex.pl',
           'tomek@urzad.gov.pl',
           'ToMeK@drogimex.pl',
           'tomek123@domena111.pl',
           'tomek_123@domena.pl',
           '11tomek@domena.pl')

invalid <- c('-tomek@domena.net',   #myślnik na początku
             '_tomek@domena.pl',    #podkreślenie na początku
             'tomek.drogimex.pl',   #brak "@"
             '@domena.pl',          #brak części przed "@"         
             'tomek@domena',        #błędna domena
             'tomek@domena.',       #błędna domena
             'tomek@-domena.pl',    #myślnik na początku domeny
             'tomek@_domena.pl',    #podkreślenie na początku domeny
             'łukasz@kórnik.gov')  #polskie znaki diaktryczne

reg <- "^[-\\w\\.]+@([-\\w]+\\.)+[a-zA-Z]+$"

library(stringr)
str_match(valid, reg)
str_detect(invalid, reg)

x <- str_detect(invalid, "^[a-zA-Z\\d]+[\\w\\d\\.\\-]*@(?:[a-zA-Z\\d]+[a-zA-Z\\d\\-]+\\.){1,5}[a-zA-Z]{2,6}$")
invalid[x]

# https://www.nafrontendzie.pl/walidacja-e-mail-za-pomoca-regexp
"const reg = /^[a-z\d]+[\w\d.-]*@(?:[a-z\d]+[a-z\d-]+\.){1,5}[a-z]{2,6}$/i;"

test_mail <- function(x){
  stringr::str_detect(x, "^[a-zA-Z\\d]+[\\w\\d\\.\\-]*@(?:[a-zA-Z\\d]+[a-zA-Z\\d\\-]+\\.){1,5}[a-zA-Z]{2,6}$")
}

test_mail(invalid)


