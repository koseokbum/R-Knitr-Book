library(shiny)
library(ggplot2)
library(plyr)
library(ggthemes)
 
shinyServer(function(input, output){

  submtcars <- reactive({
    df <- mtcars
    k <-c("cyl", "mpg", input$sel)
    df$cyl <- as.factor(df$cyl)
    df[k]
  })
  
  output$graph <- renderPlot({
    p <- ggplot(submtcars())
    p <- p+aes_string(x=input$sel, y="mpg", group=1, col="cyl")
    p <- p+geom_point(size=3)
    p <- p + xlab(input$sel)
    if(input$SEadd){
      p <- p + geom_smooth(se=TRUE, method="lm")
    }else{
      p<-p + geom_smooth(se=FALSE, method="lm") 
    }
    p <- p + ggtitle(paste0("mpg vs ",input$sel ))
    p <- p + theme(plot.title = element_text(size = rel(10)))
    p <- p + theme_igray()
    print(p)
  })
 
  output$tbl <- renderTable({
    x <- input$sel
    df <- ddply(submtcars(), .(cyl), function(df){
                                     M1 <- mean(df[,x])
                                     M2 <- mean(df$mpg)
                                     c(M1, M2)
                                    }
              ) 
                                    
    
   names(df)<-c("cyl", paste0("mean_", input$sel), "mean_mpg")
    return(df)
  })
  
  output$submtcars <- renderDataTable({
    submtcars()
  })
})