
## chapter 4--------------------------
library(ggplot2)
library(plyr)
library(reshape)
library(xtable)
library(reshape)
library(stringr)

## 4.1--------------------------------------------------------------------
names <- c("patient01", "patient02", "patient03")
bp0 <- c(135, 150, 140)
bp1 <- c(130, 140, 130)
bp3 <- c(130, 135, NA)
bp6 <- c(120, 110, 125)
df <- data.frame(names,  bp0, bp1, bp3, bp6)


df


pulse0 <- c(98, 78, 65)
pulse1 <- c(87, 66, 87)
pulse3 <- c(50, 65, NA)
pulse6 <- c(52, 77, 88)
df1 <- data.frame(pulse0, pulse1, pulse3, pulse6)
newdf<-cbind(df, df1)


newdf



mdf <- melt(newdf, id="names")
mdf$newvar <- str_sub(mdf$variable, end=-2)
mdf$followup <-str_sub(mdf$variable, -1)
ddf <- cast(mdf, names+followup~newvar)


ddf


ddf


weight <- c(74, 80, 78)
height <- c(170, 168,166)
demo <- data.frame(names, weight, height)


demo


jdf <- join(ddf, demo, by="names")
jdf <- jdf[, c("names", "weight", "height", "followup", "bp", "pulse")]
jdf


messy<-newdf
tidy <-ddf


messy


tidy


ggplot(tidy, aes(as.numeric(followup), bp, group=names, col=names))+geom_line()+scale_x_discrete(aes(followup), limits=c(0,1,3, 6))+theme_bw()


ggplot(tidy, aes(as.numeric(followup), bp, group=names, col=names))+geom_line()+scale_x_discrete(aes(followup), limits=c(0,1,3, 6))+theme_bw()


widedf <- messy


widedf


longdf <- tidy


longdf


library(reshape)


## ------------------------------------------------------------------------
widedf
mdf <-melt(widedf, id="names") #names 변수를 id로 
mdf


## ----message=FALSE-------------------------------------------------------
library(stringr)


## ------------------------------------------------------------------------
mdf$followup <- str_sub(mdf$variable, -1)
mdf$newvar <- str_sub(mdf$variable, 1, -2)


## ------------------------------------------------------------------------
mdf


## ------------------------------------------------------------------------
cdf <-cast(mdf, names+followup~newvar)


## ------------------------------------------------------------------------
cdf


## ----size='small'--------------------------------------------------------
mdf <-melt(cdf, id=c("names", "followup"))
mdf


## ------------------------------------------------------------------------
ldf <- cast(mdf, names~newvar+followup)


## ----size="small"--------------------------------------------------------
ldf


## ----echo=FALSE----------------------------------------------------------
ldf$treat<-c('no', 'yes', 'yes')
df<-as.data.frame(ldf)


## ----size='small'--------------------------------------------------------
df


## ------------------------------------------------------------------------
mdf <- melt(df, id=c("names", "treat"))
head(mdf)


## ----eval=FALSE----------------------------------------------------------
## colsplit(변수, split, names )


## ----tidy=FALSE----------------------------------------------------------
sp <-colsplit(mdf$variable, split="_",
              names=c("newvar", "followup"))
sp


## ------------------------------------------------------------------------
mdf <- cbind(mdf, sp)
head(mdf)
dim(mdf)


## ------------------------------------------------------------------------
cdf<- cast(mdf,treat+followup~newvar)
cdf


## ------------------------------------------------------------------------
cdf<-cast(mdf, treat+followup~newvar, mean)
cdf


## ----size='small'--------------------------------------------------------
cdf <- cast(mdf, treat+followup~newvar, mean, na.rm=TRUE)
cdf


## ------------------------------------------------------------------------
cast(mdf, treat+followup~newvar, range)


## ------------------------------------------------------------------------
cast(mdf, treat+followup~newvar, c(min, max))


## ----results='hide'------------------------------------------------------
iris[2,3]
iris[2, ]
iris[, 3]
iris[-2, ]
iris[c(1,2,3),]
iris[, c(2,3)]
iris[-c(1,2,3),]
iris[, -c(2,3)]
iris[iris$Sepal.Length>4,]
iris[iris$Sepal.Length>4, "Species"]


## ----size='footnotesize'-------------------------------------------------
seto <- subset(iris, Species=="setosa")
head(seto, 3)
versi <- subset(iris, Species=="versicolor")
head(versi, 3)


## ----tidy=FALSE----------------------------------------------------------
seto2 <-subset(iris, Species=="setosa", select=1:2)
head(seto2, 3)
versi2 <- subset(iris, Species=="versicolor", 
                 select=c("Sepal.Length", "Sepal.Width"))
head(versi2, 3)


## ------------------------------------------------------------------------
subiris <- iris[, -5]
re1 <- apply(subiris, 2, mean)
re1
re2 <- apply(subiris, 1, sum)
head(re2, 3)


## ------------------------------------------------------------------------
sapply(subiris, mean)


## ------------------------------------------------------------------------
sapply(subiris, mean, trim=0.5)


## ------------------------------------------------------------------------
tapply(iris$Sepal.Length, iris$Species, mean)


## ------------------------------------------------------------------------
library(plyr)


## ----size="scriptsize"---------------------------------------------------
str(iris)


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), nrow)


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), dim)


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), c(nrow, ncol))


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), function(df) {mean(df$Sepal.Length)})


## ----echo=FALSE----------------------------------------------------------
summarise(baseball,
 duration = max(year) - min(year),
 nteams = length(unique(team)))


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width))


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width), sdSW=sd(Sepal.Width))


## ----echo=FALSE----------------------------------------------------------
colwise(mean, is.numeric)(iris)


## ----echo=FALSE----------------------------------------------------------
colwise(mean, .(Sepal.Width, Sepal.Length, Petal.Width))(iris)
colwise(mean, c("Sepal.Width", "Sepal.Length", "Petal.Width"))(iris)


## ----echo=FALSE, size='small'--------------------------------------------
ddply(iris, .(Species), colwise(mean, is.numeric) )


## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), colwise(mean, c("Sepal.Length", "Sepal.Width", "Petal.Width")))


## ----size='footnotesize'-------------------------------------------------
library(ggplot2)
str(diamonds)


## ----echo=FALSE----------------------------------------------------------
ddply(diamonds, .(cut), summarise, meanPrice=mean(price))


## ----echo=FALSE----------------------------------------------------------
ddply(diamonds, .(cut, color), summarise, meanPrice=mean(price))


## ----echo=TRUE, size='small'---------------------------------------------
StudentName <- c("가", "나", "다", "라", "마")
StudentId <- 111:115
Student <- data.frame(StudentName , StudentId)
gradeA <- c("a","a","b")
SubjectA <- data.frame(StudentId=c(111, 113, 115), gradeA)
gradeB <- c("a","c","a","d")
SubjectB <- data.frame(StudentId=c(111, 112, 114, 115), gradeB)


## ------------------------------------------------------------------------
Student
SubjectA
SubjectB


## ------------------------------------------------------------------------
join(Student, SubjectA, type='left')
join(SubjectA, Student, type='left')
join(SubjectA, Student, type='right')


## ------------------------------------------------------------------------
join(SubjectA, SubjectB, type='inner')


## ------------------------------------------------------------------------
join(SubjectA, SubjectB, type='full')


## ------------------------------------------------------------------------
df1 <-join(Student, SubjectA, type='left')
df <- join(df1, SubjectB, type='left')
df


## ------------------------------------------------------------------------
st <- join(SubjectA, Student, type='left')
st


## ------------------------------------------------------------------------
st <- join(SubjectA, Student, by="StudentId", type='left')
st


## ----warning=FALSE, error=FALSE, message=FALSE---------------------------
library(dplyr)
library(ggplot2)
diamonds_df <- tbl_df(diamonds)
diamonds_df


## ------------------------------------------------------------------------
filter(diamonds_df, cut == "Premium", color=="E")


## ------------------------------------------------------------------------
filter(diamonds_df, cut == "Premium" | color == "E")


## ------------------------------------------------------------------------
select(diamonds_df, cut, color)


## ------------------------------------------------------------------------
select(diamonds_df, x:z)


## ------------------------------------------------------------------------
select(diamonds_df, -(x:z))


## ------------------------------------------------------------------------
select(diamonds_df, -(4:7))


## ------------------------------------------------------------------------
select(diamonds_df, c(carat, price, x, y))
select(diamonds_df, c(1,7, 8, 9))


## ------------------------------------------------------------------------
arrange(diamonds_df, price, carat)


## ------------------------------------------------------------------------
arrange(diamonds_df, desc(price))


## ------------------------------------------------------------------------
mutate(diamonds_df, d = x + y + z)


## ------------------------------------------------------------------------
summarise(diamonds_df, xMean=mean(x), yMean=mean(y))


## ------------------------------------------------------------------------
library(plyr)
ddply(diamonds, .(cut), summarise, priceMean=mean(price))


## ------------------------------------------------------------------------
df <- group_by(diamonds_df, cut)
df


## ------------------------------------------------------------------------
summarise(df, meanPrice = mean(price, na.rm=TRUE))


## ------------------------------------------------------------------------
summarise(df, N = n(), meanPrice = mean(price))


## ------------------------------------------------------------------------
tmp <- filter(diamonds_df, carat > 1, carat<1.5)
tmp <- group_by(tmp,  color)
tmp <- summarise(tmp, price=mean(price))
result <- arrange(tmp, desc(price))
result


## ------------------------------------------------------------------------
diamonds_df %.%
  group_by(color) %.% 
  summarise(price=mean(price)) %.%
  arrange(desc(price))


