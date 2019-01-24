server <- function(input, output, session) {
  
  values <- reactiveValues(
    file1 = NULL
  )
  
  observe({
    input$clearFile1
    input$uploadFormat
    values$file1 <- NULL
  })
  
  observe({
    values$file1 <- input$file1
  })
  
  output$summary <- renderText({
    return(paste("Uploaded file: ", values$file1$name))
  })
  
  output$resettableInput <- renderUI({
    input$clearFile1
    input$uploadFormat
    
    fileInput('file1', NULL, width="80%")
  })
  
}

ui <- bootstrapPage(
  
  tags$head(
    tags$style(".clearButton {float:right; font-size:12px;}")
  ),
  
  headerPanel("Reset file input example"),
  
  sidebarPanel(
    HTML("<button id='clearFile1' class='action-button clearButton'>Clear</button>"),
    uiOutput('resettableInput'),
    
    selectInput('uploadFormat', label = "Select upload format", 
                choices = c(
                  "Option 1" = 'f1',
                  "Option 2" = 'f2',
                  "Option 3" = 'f3'),
                selected = 'f1')
    
  ),
  
  mainPanel(
    h4("Summary"),
    verbatimTextOutput("summary")
  )
  
)

shinyApp(ui = ui, server = server)
