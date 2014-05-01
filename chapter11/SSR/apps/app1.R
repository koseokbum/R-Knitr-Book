library(ggplot2)
library(ggthemes)
library(slidify)

aestext <- function(){
  as.character(input$sel)
}
formulatext<-reactive({
  paste0("mpg~", aestext())
})
output$plot1 <- renderPlot({
  p<- ggplot(mtcars, aes_string(x=aestext(), y="mpg")) 
  p<- p + geom_point()
  if(input$SEadd){
    p<-p+geom_smooth(se=TRUE, method="lm") }
  else{
    p<-p+geom_smooth(se=FALSE, method="lm") }
  p<-p+ggtitle(paste0("mpg vs ",aestext() )) 
  p<-p+theme(plot.title = element_text(size = rel(2))) 
  p<- p + theme_igray()
  p<-p+theme_economist()
  print(p)
})
output$tbl1 <-renderPrint({
  k <- lm(formulatext(), data=mtcars)
  k$coefficients
})