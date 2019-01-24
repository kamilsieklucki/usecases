# https://blog.joda.org/2018/09/do-not-fall-into-oracles-java-11-trap.html
# https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_windows-x64_bin.zip
# 
# library(RSelenium)
# Sys.setenv("R_ZIPCMD" = "C:/Rtools/bin/zip.exe")
# Sys.setenv("JAVA_HOME" = "../jdk-11.0.2/bin/java.exe")
# x <- Sys.getenv("PATH")
# y <- ";..\\jdk-11.0.2\\bin\\"
# z <- paste0(x, y)
# Sys.setenv("PATH" = z)

# https://blog.prokulski.science/index.php/2018/06/05/webscrapping-w-r/

library(RSelenium)
Sys.setenv("R_ZIPCMD" = "C:/Rtools/bin/zip.exe")
fprof <- makeFirefoxProfile(
  list(
    browser.download.dir = "C:/temp",
    browser.download.folderList = 2L,
    browser.download.manager.showWhenStarting = FALSE,
    browser.helperApps.neverAsk.saveToDisk =  "application/octet-stream"
  )
)

RSelenium::rsDriver(port = 4444L) #browser = "firefox")

remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444L, browserName = "firefox", extraCapabilities = fprof)
remDr$open()
remDr$navigate("http://www")

# login
# szukamy elementu o okreslonej nazwie (atrybut name)
webElem <- remDr$findElement(using = 'id', value = "id")
# wysylamy do niego ciag znakow i na koniec Enter
webElem$sendKeysToElement(list("login"))

# hasło
# szukamy elementu o okreslonej nazwie (atrybut name)
webElem <- remDr$findElement(using = 'id', value = "id")
# wysylamy do niego ciag znakow i na koniec Enter, który od razu wyśle nam formularz
webElem$sendKeysToElement(list("password", key = "enter"))

Sys.sleep(7)
remDr$navigate("http://www")

Sys.sleep(5)
webElem <- remDr$findElement(using = 'css selector', "button.btn:nth-child(4)")
webElem$clickElement()

list.files("C:/temp")
Sys.sleep(10)
remDr$close()









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
