https://blog.prokulski.science/index.php/2018/06/05/webscrapping-w-r/

library(RSelenium)
RSelenium::rsDriver(port = 4444L, browser = "firefox")

# przegladarka <- remoteDriver$new()
# przegladarka$open()
# 
# przegladarka$navigate("http://www.google.com")
# 
# przegladarka$getTitle()
# 
# przegladarka$getCurrentUrl()
# 
# wyszukiwarka <- przegladarka$findElement(using = "name", value = "q")
# wyszukiwarka$sendKeysToElement(list("R Cran", key="enter"))
# 
# przegladarka$getTitle()
# 
# przegladarka$getCurrentUrl()
# 
# # przegladarka$goBack()
# 
# # szukamy elementów o określonym CSSie
# webElems <- przegladarka$findElements(using = 'css selector', "h3.r")
# # bierzemy teksty tych elementow
# resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
# resHeaders
# 
# # potrzebujemy elementu z tekstem "CRAN Packages By Name"
# webElem <- webElems[[which(resHeaders == "CRAN Packages By Name")]]
# 
# # klikamy w niego
# webElem$clickElement()



remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444L, browserName = "firefox")
remDr$open()
remDr$navigate("http://www.google.com/ncr")
remDr$getTitle()
remDr$getCurrentUrl()

# szukamy elementu o okreslonej nazwie (atrybut name)
webElem <- remDr$findElement(using = 'name', value = "q")

# wysylamy do niego ciag znakow i na koniec Enter
webElem$sendKeysToElement(list("R Cran", key = "enter"))

# szukamy elementów o określonym CSSie
webElems <- remDr$findElements(using = 'css selector', "search")
# bierzemy teksty tych elementow
resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
resHeaders

# potrzebujemy elementu z tekstem "CRAN Packages By Name"
webElem <- webElems[[which(resHeaders == "CRAN Packages By Name")]]

# klikamy w niego
webElem$clickElement()


# https://ropensci.org/tutorials/rselenium_tutorial/
webElem <- remDr$findElement(using = 'id', value = "search")
webElem <- remDr$findElement(using = 'class name', "gbqfif")
webElem <- remDr$findElement(using = 'css selector', "input.gbqfif")
webElem <- remDr$findElement(using = 'css selector', "input#gbqfq")
webElems <- remDr$findElements(using = 'css selector', "li.g h3.r")
resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
resHeaders
