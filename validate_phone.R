valid <- c("722713505",
           '722-713-505',
           '722 713 505',
           '+48722713505',
           '+48 722713505',
           '+48 722-713-505',
           '+48 722 713 505',
           '48722713505',
           '48 722713505',
           '48 722-713-505',
           '48 722 713 505')

invalid <- c('K',   #myślnik na początku
             '6842031',    #podkreślenie na początku
             '8524-966',   #brak "@"
             '022 713 50 95',          #brak części przed "@"         
             '033 879-77-79',        #błędna domena
             '62 761 49 34')

library(stringr)

x <- str_detect(valid, "[\\+d{2}]?[ -]?\\d{3}[ -]?\\d{3}[ -]?\\d{3}")
valid[x]

y <- str_detect(invalid, "[\\+d{2}]?[ -]?\\d{3}[ -]?\\d{3}[ -]?\\d{3}")
invalid[y]

test_mobile <- function(x){
  stringr::str_detect(x, "[\\+d{2}]?[ -]?\\d{3}[ -]?\\d{3}[ -]?\\d{3}")
}

test_mobile <- function(x){
  phone <- regex("
    (?:(?:(?:\\+|00)?48)|(?:\\(\\+?48\\)))? # opcjonalny numer międzynarodowy
    (?:45|5[0137]|6[069]|7[2389]|88) # kierunkowy
    (?:[-\\.\\(\\)\\s]*(\\d)){7}\\)?$ # pozostałe składowe numeru

  ", comments = TRUE)
  
  stringr::str_detect(x, phone)
}



phone <- regex("
  \\(?     # optional opening parens
  (\\d{3}) # area code
  [)- ]?   # optional closing parens, dash, or space
  (\\d{3}) # another three numbers
  [ -]?    # optional space or dash
  (\\d{3}) # three more numbers
  ", comments = TRUE)


valid <- c(
           "(12) 44 667 80",
           "(12)4466780",
           "(12) 4466780",
           "(12) 44-667-80",
           "(12)44-667-80", 
           "124466780", 
           "12 446 67 80", 
           "12 4466780", 
           "12-446-67-80",
           "12 446-67-80",
           "+48 124466780",
           "+48124466780",
           "+48 12 446 67 80",
           "+48-12-446-67-80",
           "+48 12-446-67-80",
           "48 12 446 67 80",
           "(12) 446 67 80",
           "(12) 446-67-80")


invalid <- c("(012) 44 667 80", # w teorii od (012) poprawne
             "(012)4466780",
             "(012) 4466780",
             "(012) 44-667-80",
             "(012)44-667-80",
             "(012) 446 67 80",
             "(012) 4466780",
             "4466780",
             "446 67 80",
             "446-67-80")

# Trzeba ustalić co jest dla Nas poprawnym formatem numeru stacjonarnego?
phone <- regex("
    (?:(?:(?:\\+|00)?48)|(?:\\(\\+?48\\)))? # opcjonalny numer międzynarodowy
    (?:[-\\.\\(\\)\\s]*(\\d)){9}\\)?$ # pozostałe składowe numeru

  ", comments = TRUE)

# \\+?d{2}? # opcjonalny numer międzynarodowy
#   [ -]?      # opcjonalna spacja lub myślnik
#   \\(?       # opcjonalnie nawias otwierający
#        [0]?       # opcjonalne zero
#        \\d{2}     # numer międzymiastowy
#      [)- ]?     # opcjonalnie nawias zamykający, myślnik lub spacja
#        \\d{3}
#      [ -]?      # opcjonalna spacja lub myślnik

x <- str_detect(valid, phone)
valid[x]

y <- str_detect(invalid, phone)
invalid[y]


#"^(\\+?\\d{2}[ \\-]?\\d{2}[ \\-]?|\\(?\\[d{2}d{3}])?)"
# [ \\-]?\\d{3}[ \\-]?\\d{2}[ \\-]?\\d{2}
                #"[\\(\\+]?[0]?\\d{2}?[)\\- ]?\\d{2}[ \\-]?\\d{3}[ \\-]?\\d{2}[ \\-]?\\d{2}"


test_phone <- function(x){
  phone <- regex("
    (?:(?:(?:\\+|00)?48)|(?:\\(\\+?48\\)))? # opcjonalny numer międzynarodowy
    (?:[-\\.\\(\\)\\s]*(\\d)){9}\\)?$ # pozostałe składowe numeru

  ", comments = TRUE)
  
  stringr::str_detect(x, phone)
}
# https://en.wikipedia.org/wiki/Telephone_numbers_in_Poland
test_phone <- function(x){
  phone <- regex("
    (?:(?:(?:\\+|00)?48)|(?:\\(\\+?48\\)))? # opcjonalny numer międzynarodowy
    (?:1[2-8]|2[2-69]|3[2-49]|4[1-68]|5[0-9]|6[0-35-9]|[7-8][1-9]|9[145]) # kierunkowy
    (?:[-\\.\\(\\)\\s]*(\\d)){7}\\)?$ # pozostałe składowe numeru

  ", comments = TRUE)
  
  stringr::str_detect(x, phone)
}

# https://github.com/skotniczny/phonePL
"(?:(?:(?:\+|00)?48)|(?:\(\+?48\)))?(?:1[2-8]|2[2-69]|3[2-49]|4[1-68]|5[0-9]|6[0-35-9]|[7-8][1-9]|9[145])\d{7}"

phone <- regex(
  "(?:(?:(?:\\+|00)?48)|(?:\\(\\+?48\\)))?(?:1[2-8]|2[2-69]|3[2-49]|4[1-68]|5[0-9]|6[0-35-9]|[7-8][1-9]|9[145])\\d{7}"
)

x <- str_detect(valid, phone)
valid[x]

y <- str_detect(invalid, phone)
invalid[y]



# inny przykład http://blog.tymek.cz/walidacja-numeru-telefonu/
"/^(?:\(?\+?48)?(?:[-\.\(\)\s]*(\d)){9}\)?$/"

phone <- regex(
  "^(?:\\(?\\+?48)?(?:[-\\.\\(\\)\\s]*(\\d)){9}\\)?$"
)

x <- str_detect(valid, phone)
valid[x]

y <- str_detect(invalid, phone)
invalid[y]

