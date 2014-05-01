require(rCharts)
require(plyr)

seltext <- function(){
  as.character(input$sel2)
}

dd <- function(){
  ddply(mtcars,.(cut(mtcars[, seltext()], breaks=5)), 
        summarise, MPG=mean(mpg))
}

output$chart2<-renderChart({
  df <- as.data.frame(dd())
  names(df)[1] <- seltext()
  u1 <- uPlot(seltext(), "MPG", data=df, type="Bar")
  u1$config(meta = list(
    caption = "연비(MPG)",
    vlabel  = seltext(),
    hlabel = "mpg"),
    dimension = list(
      height = "300")
  )
  u1$set(dom = 'chart2')
  u1
}) 