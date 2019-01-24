server <- function(input, output, session) {
  
  values <- reactiveValues(
    file1 = NULL
  )
  
  observe({
    input$reset
    values$file1 <- NULL
  })
  
  observe({
    values$file1 <- input$file1
  })
  
  output$summary <- renderText({
    return(paste("Uploaded file: ", values$file1$name))
  })
  
  output$resettableInput <- renderUI({
    input$reset
    
    fileInput('file1', NULL, width="80%")
  })
  
}

ui <- bootstrapPage(
 
  headerPanel("Reset file input example"),
  
  sidebarPanel(
    uiOutput('resettableInput'),
    actionButton("reset", "Reset file")
    
  ),
  
  mainPanel(
    h4("Summary"),
    verbatimTextOutput("summary")
  )
  
)

shinyApp(ui = ui, server = server)
