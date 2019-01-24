library(openxlsx)
library(dplyr)
# install.packages("installr")
# installr::install.rtools()
# The openxlsx package requires a zip application to be available to R, such as the one that comes with Rtools.
Sys.setenv("R_ZIPCMD" = "C:/Rtools/bin/zip.exe")

# vignette("formatting",package = "openxlsx")
dir.create("~/../Desktop/openslsx_example")
setwd("~/../Desktop/openslsx_example")


df <- data.frame(stringsAsFactors=FALSE,
          lp = c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L),
        data = as.Date(c("2018-04-01", "2018-04-02", "2018-04-03", "2018-04-04",
                 "2018-04-05", "2018-04-06", "2018-04-07", "2018-04-08",
                 "2018-04-09", "2018-04-10")),
    sprzedaz = c(65997351.2, 76558417.62, 39147750.98, 36439531.05, 6197396.24,
                 62972294.34, 73833720.24, 73717531.67, 48298974.24, 51562958.07),
   potencjal = c(162986392.9, 320518023.6, 355128563.5, 276185283.7, 503257223.2,
                 508863368.3, 139552092.4, 451433768.8, 460204447.5, 255248255.4)
)

df <- df %>% 
  mutate(udzial = sprzedaz / potencjal)

df

# zwykły zapis
write.xlsx(df, file = "example1.xlsx")
# zapis jako tabela
write.xlsx(df, file = "example2.xlsx", asTable = TRUE)
# zapis do kilku arkuszy
sheets <- list("sprzedaz" = df, "mtcars" = mtcars)
write.xlsx(sheets, file = "example3.xlsx", asTable = TRUE)

# Zmiana formatowania jako opcja globalna
  # options("openxlsx.borderColour" = "#4F80BD")
  # options("openxlsx.borderStyle" = "thin")
options("openxlsx.dateFormat" = "dd/mm/yyyy")
  # options("openxlsx.datetimeFormat" = "yyyy-mm-dd hh:mm:ss")
options("openxlsx.numFmt" = "#,#0.00") ## For default style rounding of numeric columns
write.xlsx(sheets, file = "example4.xlsx")

# class(df$sprzedaz) <- "currency"
# <- "accounting"
# <- "hyperlink"
class(df$udzial) <- "percentage"
# <- "scientific"
write.xlsx(df, file = "example5.xlsx")

# ustawienia wlasnych styli dla naglowka
hs1 <- createStyle(fgFill = "#4F81BD", halign = "center", valign = "center", textDecoration = "bold",
                   border = "Bottom", fontColour = "white", wrapText = TRUE)

options("openxlsx.numFmt" = "#,#0") 
class(df$udzial) <- "percentage"
write.xlsx(df, file = "example6.xlsx", headerStyle = hs1, borders = "surrounding")

# zapisanie skoroszytu do edycji, edycja i ponowny zapis
wb <- write.xlsx(df, "example7.xlsx",headerStyle = hs1, borders = "surrounding")
setColWidths(wb, sheet = 1, cols = 1:5, widths = 20)
saveWorkbook(wb, "example7.xlsx", overwrite = TRUE)



