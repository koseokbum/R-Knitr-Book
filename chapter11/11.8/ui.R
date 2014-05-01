library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("App with ggplot2"),
  sidebarPanel(
    selectInput("sel", "Choose the variable:",selected="wt",
                choices=c("wt", "hp", "disp")),
    checkboxInput("SEadd", "Add SE?", value=FALSE)  
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Summary",
               h2("Plot"),
               plotOutput("graph"),
               br(),
               h2("Table"),
               tableOutput("tbl")
              ),
      tabPanel("Data",
               dataTableOutput("submtcars")
              )
    )
  )
))