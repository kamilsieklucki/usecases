server <- function(input, output, session) {
  
  observe({
    input$btn
    shinyjs::reset("file1") 
  })
  
}

ui <- bootstrapPage(
  shinyjs::useShinyjs(),
  fileInput('file1', 'Choose File'),
  actionButton("btn", "Trigger server to reset file input")

)

shinyApp(ui = ui, server = server)
