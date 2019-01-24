server <- function(input, output, session) {
  
  observe({
    input$btn
    session$sendCustomMessage(type = "resetFileInputHandler", "file1")  
  })
  
}

ui <- bootstrapPage(
  
  fileInput('file1', 'Choose File'),
  actionButton("btn", "Trigger server to reset file input"),
  
  tags$script('
    Shiny.addCustomMessageHandler("resetFileInputHandler", function(x) {      
        var id = "#" + x + "_progress";
        var idBar = id + " .bar";
        $(id).css("visibility", "hidden");
        $(idBar).css("width", "0%");
    });
  ')
)

shinyApp(ui = ui, server = server)
