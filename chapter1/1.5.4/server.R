library(shiny)
library(XLConnect)
library(dplyr)
library(ggplot2)
library(scales)
library(ggthemes)
library(extrafont)

wb <- loadWorkbook("revenue.xlsx", create=FALSE)
df <- readWorksheet(wb, sheet=1)

shinyServer(function(input, output) {
  
  ddf <- reactive({
    df[as.numeric(input$startMonth):as.numeric(input$endMonth),]
  })
   
  output$tbl <- renderTable({
    ddf1 <- ddf()
    names(ddf1) <- c("월", "매출")
    ddf1
  }, digits=0, include.rownames=FALSE)
  
  output$tbl2 <- renderTable({
    summarise(ddf(),   해당기간합계=sum(revenue), 월평균매출=mean(revenue))
  }, digits=0,include.rownames=FALSE)
  
 output$graph <- renderPlot({
   p <- ggplot(ddf(), aes(as.factor(month), revenue, group=1))+geom_point()+geom_line()
   p <-p+scale_y_continuous(labels=comma)
   p <- p + theme_economist()
   p <- p + labs(x="월", y="매출")
   p <- p + theme(axis.title = element_text(family="NanumGothic", size=rel(1.5)))

   print(p)
 })
})
