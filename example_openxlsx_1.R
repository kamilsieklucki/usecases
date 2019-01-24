library(openxlsx)
library(dplyr)

Sys.setenv("R_ZIPCMD" = "C:/Rtools/bin/zip.exe")

dir.create("~/../Desktop/openslsx_example")
setwd("~/../Desktop/openslsx_example")


zapisz_excel <- function(df, file, cols_to_percent) {
  # zmiana formatowania dla dat
  options("openxlsx.dateFormat" = "yyyy/mm/dd")
  options("openxlsx.numFmt" = "#,#0")
  options("openxlsx.borderStyle" = "thin")
  options("openxlsx.borderColour" = "#000000")

  for (i in cols_to_percent){
    if (i %in% colnames(df)){
      class(df[,i]) <- "percentage"
    }
  }
  
  # utworzenie nowego skoroszytu
  wb <- createWorkbook()
  
  # utworzenie nowego arkusza
  addWorksheet(wb, "dane", gridLines = FALSE)
  
  # zmiana czcionki
  modifyBaseFont(wb, fontSize = 11, fontName = "Times New Roman")
  
  # usztywnienie pierwszego wiersza
  freezePane(wb, sheet = 1, firstActiveRow = 3) #firstRow = TRUE, firstCol = TRUE)
  
  # zapisanie danych w arkuszu
  hs1 <- createStyle(fgFill = "#4F81BD", halign = "center", valign = "center", textDecoration = "bold",
                     border = "Bottom", fontColour = "white", wrapText = TRUE)
  
  writeData(wb, sheet = 1, paste0("Dane na dzień: ", Sys.Date()), startRow = 1, startCol = 1) # writeDataTable
  
  writeData(wb, sheet = 1, df, startRow = 2, startCol = 1, headerStyle = hs1, borders ="all", withFilter = TRUE)
  
  # szerokość kolumn
  setColWidths(wb, sheet = 1, cols = 1:10, widths = 12.85)
  
  # # zapisuje wykres z konsloi plots
  # ggplot(data = df, aes(data, sprzedaz)) +
  #   geom_line(colour="royalblue2")
  # ## Add worksheet and write plot to sheet
  # insertPlot(wb, sheet = 1, xy = c("H", 3))
  
  
  
  # zapis do pliku
  saveWorkbook(wb, file, overwrite = TRUE)
}


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

zapisz_excel(df, "example_prime.xlsx", c("udzial"))



