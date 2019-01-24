library(shiny)

ui <- pageWithSidebar(
  headerPanel("'Reset inputs' button example"),
  
  sidebarPanel(
    numericInput("mynumber", "Enter a number", 20),
    textInput("mytext", "Enter text", "test"),
    textAreaInput("mytextarea", "Enter text", "test"),
    passwordInput("mypassword", "Enter a password", "password"),
    checkboxInput("mycheckbox", "Check"),
    checkboxGroupInput("mycheckboxgroup", "Choose a number", choices = c(1, 2, 3)),
    radioButtons("myradio", "Select a number", c(1, 2, 3)),
    sliderInput("myslider", "Select a number", 1, 5, c(1,2)),
    uiOutput("myselUI"),
    uiOutput("mydateUI"),
    tags$hr(),
    actionButton("reset_input", "Reset inputs")
  ),
  
  mainPanel(
    h4("Summary"),
    verbatimTextOutput("summary")
  )
)

server <- function(input, output, session) {
  
  initialInputs <- isolate(reactiveValuesToList(input))
  
  observe({
    # OPTIONAL - save initial values of dynamic inputs
    inputValues <- reactiveValuesToList(input)
    initialInputs <<- utils::modifyList(inputValues, initialInputs)
  })
  
  observeEvent(input$reset_input, {
    for (id in names(initialInputs)) {
      value <- initialInputs[[id]]
      # For empty checkboxGroupInputs
      if (is.null(value)) value <- ""
      session$sendInputMessage(id, list(value = value))
    }
  })
  
  output$myselUI <- renderUI({
    selectInput("mysel", "Select a number", c(1, 2, 3))
  })
  
  output$mydateUI <- renderUI({
    dateInput("mydate", "Enter a date")
  })
  
  output$summary <- renderText({
    return(paste(input$mytext, input$mynumber))
  })
}

shinyApp(ui, server)