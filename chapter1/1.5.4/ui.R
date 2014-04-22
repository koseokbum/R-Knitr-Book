library(shiny)

shinyUI(pageWithSidebar(
  
  headerPanel("월간 매출 보고"),
  
  sidebarPanel(
    helpText("계산하고자 구간을 아래에서 선택하세요."),
    textInput("startMonth", "Start Month", value="1"),
    textInput("endMonth", "End Month", value="6"),
    submitButton("선택 완료")
  ),
  
  mainPanel(
    h3("선택된 기간 동안의 매출 정보"),
    tableOutput("tbl"),
    tableOutput("tbl2"),
    plotOutput("graph")
  )
))
