# https://stackoverflow.com/questions/37862569/datatable-row-selection-inside-shiny-module
library(shiny)

# UI element of module for displaying datatable
testUI <- function(id) {
  ns <- NS(id)
  DT::dataTableOutput(ns("testTable"))
  
}
# server element of module that takes a dataframe
# creates all the server elements and returns
# the rows selected
test <- function(input,output,session,data) {
  # ns <- session$ns
  output$testTable <- DT::renderDataTable({
    data()
  }, selection=list(mode="multiple",target="row"))
  
  return(reactive(input$testTable_rows_selected))
  
}

shinyApp(
  ui = fluidPage(
    testUI("one"),
    verbatimTextOutput("two")
  ),
  server = function(input,output) {
    out <- callModule(test,"one",reactive(mtcars))
    output$two <- renderPrint(out()) 
  }
)