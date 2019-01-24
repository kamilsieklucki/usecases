library(tidyverse)
library(shinydashboard)
library(devtools)
library(rvest)

ui <- dashboardPage(
  dashboardHeader(title = "Who am I?"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Diagnoza", tabName = "diagnoza", icon = icon("terminal"), selected = TRUE),
      menuItem("Diakrytyka", tabName = "diakrytyka", icon = icon("database"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "diagnoza",
        fluidRow(
          column(
            width = 6,
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "info",
              collapsible = TRUE,
              title = "system2('whoami')",
              textOutput("whoami")
            ),
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "info",
              collapsible = TRUE,
              title = "system2('locale')",
              tableOutput("locale")
            ),
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "success",
              collapsible = TRUE,
              title = "session_info()$platform",
              tableOutput("session")
            ),
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "success",
              collapsible = TRUE,
              title = "session_info()$packages",
              tableOutput("packages")
            )
          ),
          column(
            width = 6,
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "warning",
              collapsible = TRUE,
              title = "Sys.getlocale()",
              tableOutput("getlocale")
            ),
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "warning",
              collapsible = TRUE,
              title = "Sys.getenv()",
              tableOutput("env")
            )
          )
        )
      ),
      tabItem(
        tabName = "diakrytyka",
        fluidRow(
          column(
            width = 6,
            box(
              width = NULL,
              solidHeader = TRUE,
              status = "info",
              collapsible = TRUE,
              title = "test",
              tableOutput("diakrytyka_tabela")
            )
          )
        )
      )
    )
  )
)

server <- function(input, output) {
  output$whoami <- renderText({system2("whoami", stdout = TRUE)})
  output$locale <- renderTable({system2("locale", stdout = TRUE) %>% enframe() %>% separate(value, c("name", "value"), "=")})
  output$getlocale <- renderTable({Sys.getlocale() %>% str_split(";") %>% unlist() %>% enframe() %>% separate(value, c("name", "value"), "=")})
  output$session <- renderTable({session_info()$platform %>% enframe() %>% unnest()})
  output$packages <- renderTable({session_info()$packages %>% as_tibble()})
  output$env <- renderTable({Sys.getenv() %>% enframe()})
  
  
  diakrytyka <- "https://pl.wikipedia.org/wiki/Pangram" %>%
    read_html() %>%
    html_nodes("ul:nth-child(5) li") %>%
    html_text() %>%
    tibble(diakrytyka = .)
  
  output$diakrytyka_tabela <- renderTable(diakrytyka)
}

shinyApp(ui, server)
