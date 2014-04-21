
## ----echo=FALSE, message=FALSE-------------------------------------------
opts_chunk$set(echo=FALSE, comment=NA)
library(XLConnect)
library(dplyr)
library(ggplot2)
library(scales)
library(ggthemes)


## ------------------------------------------------------------------------
wb <- loadWorkbook("revenue.xlsx", create=FALSE)
df <- readWorksheet(wb, sheet=1)


## ----results='asis'------------------------------------------------------
kable(df, digits=0, format='pandoc')


## ----fig.width=7, fig.height=4-------------------------------------------
df$month <- as.factor(df$month)
p <- ggplot(df, aes(month, revenue, group=1))+geom_point()+geom_line()
p <-p+scale_y_continuous(labels=comma)
p <- p+ theme_economist()
p


