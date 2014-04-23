## 7.1.2 그래픽 디바이스, 전통적 그래픽, 그리드 그래픽

## png device로 그래프 출력하기 

png(file="example.png")
plot(mtcars$wt, mtcars$mpg)
dev.off()


## layout() 함수 사용하기

layout(matrix(3:1))
layout.show()


layout(matrix(c(2,1,0,3), ncol=2))
layout.show(3)


layout(matrix(c(2, 1, 2, 3), ncol = 2), heights = c(1.5, 1), respect = T) 
hist(rnorm(100))
hist(rnorm(200))
hist(rnorm(300))


## 저수준 함수와 고수준 함수
## 여기서 lines(),abline() 함수는 저수준 함수
## hist(), plot() 함수는 고수준 함수이다.
par(mfrow=c(2,1))
set.seed(7)
random <- rnorm(1000)
hist(random, prob=TRUE)
lines(density(random), col='red')

plot(mpg~wt, data=mtcars)
abline(lm(mpg~wt, data=mtcars), col='red')


## legend() 함수를 사용하여 범례 추가하기 
## title() 함수를 사용하여 제목 붙히기
par(mfrow=c(1,1))
plot(mtcars$wt, mtcars$mpg, pch=(1:3)[as.factor(mtcars$cyl)])
legend("topright", legend=levels(as.factor(mtcars$cyl)), pch=1:3)
title(main="mpg vs wt and cyl")

## ggplot2 패키지를 사용한 그래프 그리기
library(ggplot2)
ggplot(mtcars, aes(wt, mpg, shape=as.factor(cyl)))+geom_point()+ggtitle("mpg vs wt") + scale_shape_discrete(name="Number of \ncylinder")

## ggplot2의 강력한 통계 서머리 기능
ggplot(mtcars, aes(wt, mpg))+geom_smooth(method='lm', se=TRUE)

## ggplot2를 사용한 트렐리스(조건부) 그래프 만들기
ggplot(mtcars, aes(wt, mpg))+geom_point()+facet_grid(cyl~gear)











