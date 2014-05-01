## ----echo=FALSE, cache=FALSE, message=FALSE------------------------------
library(ggplot2)
library(plyr)
library(reshape)

#' 
#' \chapter{왜 데이터하면 R인가?}
#' 
#' 이 장에서는 해들리 위캄\mysub{Hadley Wickham}라는 통계학자의 패키지들을 사용하여 R로 데이터를 다루는 방법의 일면을 소개하고자 한다.  그는 \texttt{ggplot2}, \texttt{plyr}, \texttt{reshape}, \texttt{stringr}, \texttt{lubridate} 등을 비롯하여 유용한 R 패키지를 많이 발표해 왔다.
#' 
#' R과 관련한 무수히 많은 패키지들이 있는데, 그 중 그가 개발한 패키지들이 인기가 많은 이유는 그가 만든 패키지들은 논리와 이론에 맞게 설계되어 있기 때문일 것이다. 예를 들어, R 그래픽에서 유명한 \texttt{ggplot2}라는 패키지는 기존의 ``그래픽의 문법"\mysub{grammer of graphics}라는 통계 그래픽의 이론을 기반으로 한다. 논리와 이론이란 어떤 특수한 것들에 대한 일반화하여 정리한 것이다. 따라서, 그의 패키지들은 일반화된 논리와 이론은 가지고 수많은 특수한 문제들을 해결할 수 있어서 매우 유용하다. 
#' 
#' 
#' 이 장에서는 그가 제시한 타이디 데이터(tidy data)라는 개념을 바탕으로, 타이디 툴(tidy tool)로 제시하는 \texttt{reshape}과 \texttt{plyr}, 최근에 발표한 \texttt{dplyr} 패키지를 소개하려 한다. 
#' 
#' \section{정리된 데이터와 정리되지 않은 데이터}
#' \index{R!정리된 데이터}
#' \index{R!정리되지 않은 데이터}
#' 
#' 많은 사람들이 엑셀로 데이터를 정리하는 경우가 많으므로, 엑셀에 데이터를 정리한다고 가정해 보자. 일반적으로 데이터는 표(table)로 정리한다. 엑셀 시트는 이런 표의 일종이다. 
#' 
#' 혈압약을 치료효과를 보는 연구 데이터를 수집한다고 생각해 보자. 치료군에 속하는지 대조군(위약)에 속하는 지는 아직 모르는 상태이며, 어떤 환자의 수축기 혈압을 측정한다. \texttt{bp0}는 위약이든 진짜 약이든 약물 투여전 혈압이고, \texttt{bp1}은 한 달후, \texttt{bp3}는 3 개월후, \texttt{bp6}는 6개월 후 방문했을 때의 수축기 혈압이라고 한다. 흔히 엑셀에서 다음과 같은 모습의 표로 데이터를 정리한다.
#' 
#' 
## ----echo=FALSE, include=FALSE-------------------------------------------
library(xtable)
names <- c("patient01", "patient02", "patient03")
bp0 <- c(135, 150, 140)
bp1 <- c(130, 140, 130)
bp3 <- c(130, 135, NA)
bp6 <- c(120, 110, 125)
df <- data.frame(names,  bp0, bp1, bp3, bp6)

#' 
## ----echo=FALSE----------------------------------------------------------
df

#' 
#' 이렇게 표로 데이터를 정리할 때, 보통은 열에는 변수을 배치하고, 행에는 케이스를 배치한다. 이런 측면에서 위의 표에서 잘못된 것은 없다. 간단히 투약 전과 투약후 6개월간의 혈압차이가 있는가를  본다면, 보통 \texttt{bp0}의 값에서 \texttt{bp6}의 값을 빼고, 이것을 나중에 치료군과 대조군으로 분리하여 비교하면 될 것이다.
#' 
#' 여기에 맥박에 대한 데이터를 다음과 같이 추가했다.
#' 
## ----echo=FALSE----------------------------------------------------------
pulse0 <- c(98, 78, 65)
pulse1 <- c(87, 66, 87)
pulse3 <- c(50, 65, NA)
pulse6 <- c(52, 77, 88)
df1 <- data.frame(pulse0, pulse1, pulse3, pulse6)
newdf<-cbind(df, df1)

#' 
## ----echo=FALSE----------------------------------------------------------
newdf

#' 
#' 변수의 갯수가 늘수록 표는 옆으로 크게 늘어날 것이다. 더욱 큰 문제는 이 표에 포함되어 있는 시간(투야전, 1개월, 3개월, 6개월후)에 대하여 어떤 분석을 할 때 일어난다. 시간이라는 변수를 얻기 위해서 다시 표를 정리하는 수 밖에 없을 것이다. 할 수는 있겠지만 표를 이리저리 짜집기해야 한다. 이런 문제가 발생하는 이유는 앞의 표에서 하나의 열이 두 개의 정보를 가지고 있기 때문이다. 예를 들어 bp6는 혈압이라는 정보와 6개월후에 재었다는 두 개의 정보를 가지고 있다. 이런 문제가 발생하지 않도록 하기 위해서는 하나의 열을 하나의 변수를 나타내도록 표를 설계할 필요가 있다.
#' 
#' 그리고, 이런 문제가 발생하는 것은 무엇을 행으로 정해야 하는가와 관련되어 있다. 즉, 타이디 데이터 이론에서 이야기하는 실험단위(experimental unit)과 관찰단위(observational unit)을 혼동하기 때문이다. 위의 예에서는 하나의 환자는 하나의 실험단위가 된다. 관찰단위는 각 환자들의 방문이어야 한다. 실험단위가 아닌 관찰단위가 표에서 하나의 행이 되어야 한다. 
#' 
#' \index{실험단위}
#' \index{관찰단위}
#' 
#' 사실은 이런 관찰단위로 행을 만드는 것이 더 자연스러운 것이다. 왜냐하면 데이터가 모아지는 대로 데이터를 정리하는 것이기 때문이다.
#' 
#' 
## ----echo=FALSE, message=FALSE, warning=FALSE----------------------------
library(reshape)
library(stringr)
library(xtable)
mdf <- melt(newdf, id="names")
mdf$newvar <- str_sub(mdf$variable, end=-2)
mdf$followup <-str_sub(mdf$variable, -1)
ddf <- cast(mdf, names+followup~newvar)

#' 
#' 방분할 때마다, 환자의 id와 방문횟수를 확인하고, 혈압과 맥박을 순차적으로 기록하고, 이를 환자순으로 정렬하였다면 다음과 같은 표가 될 것이다. 이러한 표가 데이터 분석에 적합한 타이디 데이터(tidy data)가 된다.
#' 
## ----echo=FALSE----------------------------------------------------------
ddf

#' 
#' 또 하나의 개념은 관찰타입(observational type)에 관한 것이다. 타이디 데이터 이론에 의하면 하나의 표에는 하나의 관찰타입을 사용하도록 하고 있다. 예를 들어 위의 자료에서 인구학적 특성(생년월일, 키, 체중 등)을 마지막 표에 추가한다면 행으로 보았을 때 한 환자가 4 행씩 차지하고 있으므로 이들 값이 네 번씩 중복되는 표를 얻기 될 것이다. 이런 경우는 별도의 표로 작성하는 것이 원칙이다. 앞에서 본 데이터에 처음 키와 체중에 데이터는 있을 때는 별도의 테이블로 정리하는 것이 좋다. 즉, 다음과 같이 2 개의 표로 관리하고 필요한 경우 연결시켜 작업한다.
#' 
## ----echo=FALSE----------------------------------------------------------
ddf

#' 
## ----echo=FALSE----------------------------------------------------------
weight <- c(74, 80, 78)
height <- c(170, 168,166)
demo <- data.frame(names, weight, height)

#' 
## ----echo=FALSE----------------------------------------------------------
demo

#' 
#' 이러한 원리는 관계형 데이터베이스를 설계하는 수학적 원리인 데이터베이스 정규화라는 개념과 통하는 것이다. 이러한 데이터베이스 정규화로 데이터의 중복을 피할 수 있다. 이 원칙을 따르지 않은 경우 필연적으로 중복은 불가피하다. 위 표들을 하나의 표로 정리한다면 다음과 같을 것이다. 여러 중복된 데이터를 확인할 수 있을 것이다. \index{데이터베이스 정규화}
#' 
## ----echo=FALSE----------------------------------------------------------
jdf <- join(ddf, demo, by="names")
jdf <- jdf[, c("names", "weight", "height", "followup", "bp", "pulse")]
jdf

#' 
#' 이상을 정리해 보면 타이디 데이터란 다음과 같은 규칙을 따른다고 한다.
#' \index{tidy data}
#' 
#' \begin{enumerate}
#'   \item 하나의 변수는 하나의 열을 만든다.
#'   \item 하나의 관찰단위가 하나의 행을 형성한다.
#'   \item 하나의 표는 한 종류의 관찰타입에 대한 정보를 포함한다.
#' \end{enumerate}
#' 
#' 따라서, 데이터클리닝이란 정리되지 않은 데이터\mysub{messy data}를 정리된 데이터\mysub{tidy data}로 바꿔가는 과정이라고 할 수 있을 것이다.
#' 
#' 위에서 정리되지 않은 데이터셋과 정리된 데이터 셋을 보자. 다음은 정리되지 않은 것이다. 
#' 
## ----echo=FALSE----------------------------------------------------------
messy<-newdf
tidy <-ddf

#' 
## ------------------------------------------------------------------------
messy

#' 
#' 다음은 정리된 데이터셋이다.
#' 
## ------------------------------------------------------------------------
tidy

#' 
#' 
#' 이 두 데이터셋으로 혈압의 변화를  그래프를 그린다고 생각해 보자. 데이터를 눈으로 읽어서 손으로 그린다면 큰 차이가 없을 것이다. 하지만, 데이터가 1200 명의 데이터라면 컴퓨터로 그릴 수 밖에 없다. 이런 경우 \texttt{messy}라는 데이터셋으로 작업하기 위해서는 여러 중간 과정을 거쳐야 한다. 반면에 \texttt{tidy}라는 데이터셋은 아래의 간단한 코딩으로 작업을 마무리 할 수 있다.
#' 
## ----echo=TRUE,fig.show='hide', fig.width=7, fig.height=3.5, fig.align='center', size='scriptsize'----
ggplot(tidy, aes(as.numeric(followup), bp, group=names, col=names))+geom_line()+scale_x_discrete(aes(followup), limits=c(0,1,3, 6))+theme_bw()

#' 
## ----echo=FALSE, fig.width=7, fig.height=3.5, fig.align='center'---------
ggplot(tidy, aes(as.numeric(followup), bp, group=names, col=names))+geom_line()+scale_x_discrete(aes(followup), limits=c(0,1,3, 6))+theme_bw()

#' 
#' 
#' 데이터를 자유자재로 다뤄서 때로는 R이 계산에 접합하도록 때로는 사람들이 이해하기 편한 모양으로 전환할 수 있다면 데이터를 더 잘 이해하고 정리할 수 있고 분석에 있어 생산성을 높일 수 있을 것이다.
#' 
#' 이러한 타이디 툴로써 \texttt{reshape}과 \texttt{plyr}이라는 패키지 사용법을 간략하게 소개하려 한다.
#' 
#' \section{reshape 패키지를 이용한 데이터셋 폼 변환}
#' \index{reshape 패키지!관련 장절}
#' 
#' 먼저 와이드 폼(wide form)과 롱 폼(long form)을 구분하여 보자. 와이드 폼과 롱 폼은 같은 정보를 표와 같은 모습으로 표현할 때 어떤 형태를 가지는 지를 말한다. 아래 두 데이터셋을 같은 정보를 담고 있는데 그 모습이 다르다.
#' 
#' 
## ----echo=FALSE----------------------------------------------------------
widedf <- messy

#' 
#' 와이드 폼은 다음과 같다. 
#' 
## ------------------------------------------------------------------------
widedf

#' 
#' 반면, \texttt{longdf}라는 데이터는 상대적으로 롱 폼이다.
#' 
## ----echo=FALSE----------------------------------------------------------
longdf <- tidy

#' 
## ------------------------------------------------------------------------
longdf

#' 
#' 
#' 가끔은 R에서 분석하게 알맞도록 또는 사람이 읽기 현하게 이런 폼들을 자유자재로 변환할 필요가 있다. \texttt{reshape}이라는 패키지(\cite{reshape})를 이용하면 쉽게 이러한 작업을 할 수 있다. 단순히 표를 돌려 놓는다기 보다는 필요에 따라 재배치할 수 있다.
#' 
#' \mycode{reshape} 패키지에는 \texttt{melt()}와 \texttt{cast()}라는 2개의 핵심 함수가 있다.  철을 녹이고, 다시 틀에 넣어 모양을 만드는 과정에 비유하여, 녹이는 함수를 \mycode{melt()}, 모양을 만드는 함수를 \mycode{cast()}라고 하였다. 먼저 패키지를 로딩한다.
#' 
## ----message=FALSE-------------------------------------------------------
library(reshape)

#' 
#' 
#' \subsection{melt() 함수와 cast() 함수}
#' \index{reshape 패키지!melt()}
#' \index{reshape 패키지!cast()}
#' 
#' 데이터 프레임이 가장 일반적인 데이터 형태인 경우가 많아 데이터 프레임을 기준으로 설명한다. \mycode{reshape}을 이용하여 데이터프레임을 녹이기 위해서는 변수들의 2개로 역할을 나눠야 한다. 하나는 id 역할을 하는 것이고, 나머지는 \texttt{measure} 역할을 하는 것이다. 이들 옵션에서 그 변수들을 지정한다. 어떤 데이터셋에서 \texttt{id}로 변수를 지정하면 나머지는 \texttt{measure} 역할을 한다. \texttt{measure}를 정하면 나머지는 \texttt{id} 역할을 한다. \texttt{c()} 함수를 이용하여 여러 변수들을 지정할 수 있다.
#' 
#' \begin{itemize}
#'   \item \texttt{id}: 데이터를 카테고리로 구분하는 역할을 하는 변수들이다. 
#'   \item measured: 측정값을 말한다.
#' \end{itemize}
#' 
#' 예를 들어 다음 \texttt{widedf}에는 \texttt{names}라는 변수가 환자 이름이므로 이것을 id 역할로 설정한다.
#' 
## ------------------------------------------------------------------------
widedf
mdf <-melt(widedf, id="names") #names 변수를 id로 
mdf

#' 
#' 어떻게 바뀌었는지 잘 비교할 필요가 있다. \mycode{id}로 지정한 \mycode{names}만 제외한 나머지 변수들을 \texttt{variable}이라는 변수의 각 값으로 들어가고, 원래의 측정된 값은 \texttt{value}라는 변수의 값으로 바뀌었다는 것을 확인할 수 있다.
#' 
#' 이렇게 만들고 나면, \texttt{variable}이라는 변수에서 혈압(bp)과 맥박(pulse)와 방문한 달의 기록을 분리하는 것은 어렵지 않다. 문자와 숫자를 분리하기 위해서 \mycode{stringr} 패키지(\cite{stringr})의 \texttt{str\_sub()} 함수를 이용해 본다.
#' 
## ----message=FALSE-------------------------------------------------------
library(stringr)

#' 
## ------------------------------------------------------------------------
mdf$followup <- str_sub(mdf$variable, -1)
mdf$newvar <- str_sub(mdf$variable, 1, -2)

#' 
#' 그러면 \texttt{mdf} 데이터프레임은 다음과 같이 된다.
#' 
## ------------------------------------------------------------------------
mdf

#' 
#' 이렇게 변형한 다음 \texttt{cast()} 함수를 이용하여 원하는 형태로 만들 수 있다.
#' 
#' 
#' \texttt{cast()}함수는 다음과 같은 형태로 사용한다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' cast(molten, castingFormula, func)
#' \end{lstlisting}
#' 
#' 
#' \texttt{molten}은 \texttt{melt()}함수를 이용하여 녹인 데이터를 말한다. \texttt{cast()} 함수에서는 데이터를 배치의 일종의 식\mysub{formula}로 표시한다. 이것을 캐스팅 포뮬러(casting formula)라고 부르고, 다음과 같은 모습을 가지고 있다.
#' 
#' \begin{kframe}
#' \begin{verbatim}
#' 열변수1+열변수2~행변수1+행변수2
#' \end{verbatim}
#' \end{kframe}
#' 
#' 
#' 이 식에는 데이셋에 있는 변수 이외에도 특수한 목적으로 쓰이는 기호들이 있다. \texttt{.}은 변수가 없음을 의미하고, \texttt{...}은 캐스팅 포뮬러에 명시되지 않은 나머지 모든 변수를 의미한다. 이런 식을 이용하여 출력물의 배치를 결정한다. \verb|~|의 왼쪽에 나열한 변수들을 열에 배치되고, 오른쪽 변수들은 행에 배치된다. 
#' 
#' \texttt{cast()} 함수의 사용법을 그림 \ref{fig:cast}에 간략하게 요약했다. \\
#' 
#' 
#' {\centering\includegraphics[scale=.35]{/Users/koseokbum/Dropbox/winImages/cast.png}%
#' \outfigcaption{cast() 함수의 사용법}\label{fig:cast}}
#' 
#' 그림이 무엇을 의미하는지 살펴보자. 
#' 
## ------------------------------------------------------------------------
cdf <-cast(mdf, names+followup~newvar)

#' 이렇게 하면, \texttt{names}와 \texttt{followup}은 각각 하나의 열을 구성한다. 식의 오른쪽에 \texttt{newvar}가 있는데, 위에서 살펴보면 \texttt{newvar}는 \texttt{bp, pulse}라는 값을 가지고 있다. 이 값들을 풀어낸 것들이 열이 된다. 결과를 보자.
#' 
## ------------------------------------------------------------------------
cdf

#' 
#' 이제 반대로 \texttt{cdf}와 같은 롱 폼의 데이터 프레임을 와이드 폼으로 바꾸려면 어떻게 해야 할까? 다시 녹이고, 다시 틀을 짜면 된다. 녹일 때는 이번에 \texttt{id} 역할을 하는 것은 \texttt{names, followup} 두 변수를 사용한다. 어떤 변수를 \texttt{id}로 선택할 지는 어떤 변수가 데이터를 나눠주는 변수인 지를 생각한다. 
#' 
#' 
## ----size='small'--------------------------------------------------------
mdf <-melt(cdf, id=c("names", "followup"))
mdf

#' 
#' 다시 이것은 \texttt{cast()} 함수로 재구성 해 보자. 이번에는 식의 오른쪽을 다음과 같이 해 본다. 
## ------------------------------------------------------------------------
ldf <- cast(mdf, names~newvar+followup)

#' 
#' 이렇게 2개 이상의 변수가 오른쪽에 올 때의 열의 구성은 값들의 조합으로 이뤄진다. 즉, newvar가 bp, pulse라는 두 종류의 값이 있고, \texttt{followup}에는 0, 1, 3, 6이라는 네 종류의 값이 있다. 그래서, 이들의 조합인 모두 8개의 열이 만들어진다. 연결은 언더바(\_)가 사용된다. 그렇게 하여 다음과 같은 와이드 폼을 얻는다.
#' 
## ----size="small"--------------------------------------------------------
ldf

#' 
#' \subsection{데이터 정리와 보조 함수}
#' 
#' 앞에서 만들어진 \texttt{ldf}라는 데이터 프레임에 치료 여부를 알려주주는 \texttt{treat}라는 변수가 추가된 새로운 데이터 프레임으로 설명을 시작한다.
#' 
## ----echo=FALSE----------------------------------------------------------
ldf$treat<-c('no', 'yes', 'yes')
df<-as.data.frame(ldf)

#' 
#' 
## ----size='small'--------------------------------------------------------
df

#' 
#' 이 데이터셋에서 치료군과 치료하지 않은 군의 혈압(bp)과 맥박(pulse)의 변동에 대하여 데이터를 정리해 보려고 한다. 
#' 
#' R로 처리할 때는 이런 와이드 폼이 아니라 롱 폼이 필요하다. 계산하도록 할 때는 철저히 하나의 셀에는 하나의 정보를 담고 있도록 해야 한다. 즉, 위에서는 추적기간과 혈압, 추적기간과 맥박이 결합된 형테로 셀을 구성하기 때문에 이것을 풀 필요가 있다. 다음과 같이 한다. 
#' 
#' 가장 먼저 데이트를 녹인다. 이번에는 names라는 변수와 \texttt{treat}라는 변수가 데이터를 구분하는 역할을 하기 때문에 이 변수들을 id로 설정한다.
#' 
## ------------------------------------------------------------------------
mdf <- melt(df, id=c("names", "treat"))
head(mdf)

#' 
#' 여기서 \texttt{variable}이라는 변수를 분리해야 한다. 여기서는 \texttt{\_}와 같은 기호로 분리되어 있는 경우는 \mycode{colsplit()}이라는 \texttt{reshape} 패키지에 있는 보조 함수를 이용한다. 사용법은 다음과 같다. 
#' 
## ----eval=FALSE----------------------------------------------------------
## colsplit(변수, split, names )

#' 
#' \texttt{split}에는 분리하는 기호를, \texttt{names}에는 분리한 다음에 쓸 변수의 이름을 쓴다.
#' 
## ----tidy=FALSE----------------------------------------------------------
sp <-colsplit(mdf$variable, split="_",
              names=c("newvar", "followup"))
sp

#' 
#' 이렇게 만들어진 데이터 프레임을 \texttt{cbind()} 함수를 이용하여 결합한다.
#' 
## ------------------------------------------------------------------------
mdf <- cbind(mdf, sp)
head(mdf)
dim(mdf)

#' 
#' 지금부터 데이터 정리에 대해 알아보려 한다. 캐스팅 포뮬러로 데이터를 재배치하는 과정에 거의 대부분의 경우는 데이터 정리가 불가피하다. 캐스팅 포뮬러의 왼쪽항은 열에 배치되는 변수가 큰 카테고리를 가질 경우, 예를 들어 위에서는 \texttt{treat}라는 변수만을 이용할 때는 no, yes 값만을 가지기 때문에 딱 2 행만 가질 것이다. 그래서, 위의 데이터가 2개의 행을 가진 데이터로 변하면서 데이터 정리가 필요하다. 다음과 같이 왼쪽에 \texttt{teat}, \texttt{followup}이라는 변수를 배치하면 \texttt{followup}이 0, 1, 3, 6 이라는 4 개의 값을 가지므로 이들을 조합한 총 8개의 행이 만들어 진다. 이 경우에도 총 24개의 행이 8개의 행으로 줄어들기 때문에 데이터 정리가 필요해 진다. 다음과 같이 실행해 보자.
#' 
## ------------------------------------------------------------------------
cdf<- cast(mdf,treat+followup~newvar)
cdf

#' 
#' 출력결과를 보면 aggregation이 발생해서 정리하는 함수가 필요한데, 디폴트로 갯수를 의미하는 \texttt{length()} 함수가 사용되었다는 것을 알려 준다. 24개의 행이 8개로 줄면서 해당되는 셀에 그 갯수가 들어갔다는 의미이다. \texttt{length()} 함수 대신에 다른 함수들이 적용가능하다. 평균값을 구하는 \texttt{mean()} 함수를 지정해 보도록 한다.
#' 
## ------------------------------------------------------------------------
cdf<-cast(mdf, treat+followup~newvar, mean)
cdf

#' 
#' \texttt{mean()} 함수를 괄호 없이 준다. 결과를 보면 결측치인 NA가 있어서 NA가 포함된 평균계산이 NA로 되는 것을 본다. 이런 NA를 빼서 계산하도록 하는 인자는 보통 \texttt{mean(x, na.rm=TRUE)} 방식으로 계산한다. \texttt{cast()} 함수 안에서 쓸 때는 함수를 쓴 다음에 쉼표를 쓰고 적으면 된다. 
#' 
## ----size='small'--------------------------------------------------------
cdf <- cast(mdf, treat+followup~newvar, mean, na.rm=TRUE)
cdf

#' 
#' 어떤 함수들은 여러 결과를 출력한다. 예를 들어 \texttt{range()}라는 함수는 최소값과 최대값을 출력한다. 이 경우도 조합하여 열을 만든다. \texttt{newvar}가 \texttt{bp, pulse}가 있고, \texttt{range()} 함수의 최소값, 최대값을 조합하여 4개의 열을 만든다. 
#' 
## ------------------------------------------------------------------------
cast(mdf, treat+followup~newvar, range)

#' 
#' 끝에 데이터 정리를 위해 여러 함수들을 벡터로 묶어서 제시할 수도 있다. 따라서, 데이터 정리를 자유자재로 할 수 있다.
#' 
## ------------------------------------------------------------------------
cast(mdf, treat+followup~newvar, c(min, max))

#' 
#' \texttt{cast()} 함수은 이외에도 \texttt{subset, margins} 등의 옵션을 사용하여 조건에 맞는 것들만을 다시 추려내거나 마진을 구할 수도 있다.
#' 
#' 
#' 
#' \section{plyr 패키지를 사용하여 데이터 다루기}
#' \index{plyr 패키지!관련 장절}
#' 
#' 어떤 자료를 특정한 기준에 따라 분류하고, 이를 정리하는 작업은 데이터를 다룰 때 흔하게 접하게 되는 문제이다. plyr 패키지를 내놓으며 저자 해들리 위캄은 이것은 ``Split-apply-combine strategy"라고 명명했다. Split이라는 말은 어떤 자료를 특정한 기준에 따라 나눈다는 의미이다. Apply라는 말은 이렇게 나눠진 subdata에 대하여 합, 평균 등으로 어떤 함수를 적용한다는 의미를 가진다. Combine한다는 말은 이렇게 구한 값들을 다시 하나의 결과물로 내놓는다는 의미이다. 
#' 
#' 여기서는 Split, Apply, Combine하는 과정들을 따로 살펴보고 난 다음 pylr 패키지를 다룰려고 한다.
#' 
#' \subsection*{Split하는 방법}\label{sec:split}
#' 
#' R에서 가장 흔히 사용하는 데이터 프레임을 대상으로 연습해 보자. \texttt{iris} 데이터셋은 데이터프레임을 이용한다.
#' 
#' \begin{description}
#'   \item[Indexing을 이용하는 방법]
#' \end{description}
#' 
#' 벡터 인덱싱을 이용하여 자료를 일정한 기준으로 쉽게 나눌 수 있다. 일반적인 문법은 다음과 같다.
#' \index{R!벡터 인덱싱}
#' \begin{kframe}
#' \begin{verbatim}
#' 데이터프레임Name[행, 열]
#' \end{verbatim}
#' \end{kframe}
#' 
#' 위의 행과 열에는 다음과 같이 사용한다.
#' 
#' \begin{itemize}
#'   \item 양의 정수가 사용되면, 해당 위치의 행과 열을 의미한다.
#'   \item 빈칸으로 둔 경우는 모든 행 또는 모든 열이 된다.
#'   \item 음의 정수가 사용되는 해당 위치의 행 또는 열은 제외한다는 의미이다.
#'   \item 조건식을 넣으면 조건식의 참인 행과 열이 선택된다.
#'   \item 정수로 이뤄진 vector를 넣으면, 해당 vector의 위치들에 있는 행, 열을 선택한다.
#' \end{itemize}
#' 
#' 이들 규칙은 서로 혼합하여 사용하면 원하는 대로 자료를 골라낼 수 있다. 아래는 하나의 예인데, 규칙과 결과를 대조하면서 충분히 연습하는 것이 좋다.
#' 
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

#' 
#' \begin{description}
#'   \item[subset()함수의 이용]
#' \end{description}
#' \index{R!subset()}
#' 
#' 위와 같은 방법은 잘 이해하면 매우 편리하고 간결하게 코드를 작성할 수 있는데, 단점은 코드를 읽기 어렵게 한다. \mycode{subset()}함수를 이용하면 보다 분명하게 코드를 작성할 수 있다. 다음과 같이 사용한다.
#' 
#' \begin{kframe}
#' \begin{verbatim}
#' subset(데이터프레임, 행선택조건, select=열선택)
#' \end{verbatim}
#' \end{kframe}
#' 
#' 다음은 그 사용예이다.
## ----size='footnotesize'-------------------------------------------------
seto <- subset(iris, Species=="setosa")
head(seto, 3)
versi <- subset(iris, Species=="versicolor")
head(versi, 3)

#' 
#' \mycode{subset()}함수의 \texttt{select} 옵션을 사용하면 열도 선택이 가능하다. 이런 기능들을 합쳐 생각해 보면, subset()함수는 \verb|[ ]|의 기능과 일치하게 사용할 수 있다. 
#' 
## ----tidy=FALSE----------------------------------------------------------
seto2 <-subset(iris, Species=="setosa", select=1:2)
head(seto2, 3)
versi2 <- subset(iris, Species=="versicolor", 
                 select=c("Sepal.Length", "Sepal.Width"))
head(versi2, 3)

#' 
#' 
#' 이들은 데이터셋을 조건에 따라 나누기만 한다. 나눠진 데이터셋에 어떤 계산을 하는 내용은 다음으로 이어진다.
#' 
#' \subsection*{Apply 함수들}
#' \index{R!apply 함수들}
#' 
#' R에는 apply 계통의 함수들이 많다. 어떤 데이터를 특정 기준에 따라 함수를 적용할 때 사용한다. 먼저 단순한 \texttt{apply()} 함수가 있다. 일반적인 형태는 다음과 같다.
#' 
#' \begin{kframe}
#' \begin{verbatim}
#' apply(data, 행이면 1을 열이면 2를 쓴다. 적용할 함수)
#' \end{verbatim}
#' \end{kframe}
#' 
#' 행에 따라 정리할 것이라면 1을 쓰고, 열에 따라 정리할 것이라면 2를 쓴다. 적용할 함수는 ()없이 이름을 써준다. 함수가 데이터에 적용될 때 계산이 안되는 경우는 \texttt{NA}를 내보낸다. 평균은 숫자형 데이터에만 적용되기 때문에 평균을 적용할 때 팩터를 주면 오류가 발생한다. \texttt{iris}에서 Species를 제외한 \texttt{subiris}란 데이터셋을 가지고 설명한다.
#' 
## ------------------------------------------------------------------------
subiris <- iris[, -5]
re1 <- apply(subiris, 2, mean)
re1
re2 <- apply(subiris, 1, sum)
head(re2, 3)

#' 
#' 두 번째 인자로 2를 쓴 경우는 열에 대하여 계산한다는 의미이고, 1을 쓴 경우는 행에 대해서 계산한다는 의미이다. 대부분의 경우는 행보다는 열에 대한 계산이 많다. 일반적으로 열에 변수를 배치하기 때문이다. 이런 경우 간단히, 간단히 한다고 해서, \texttt{sapply()} 함수를 쓸 수 있다. 1, 2 등을 쓰지 않으며, 열에 대해서 계산한다고 이해하면 된다. 
#' 
#' \index{R!sapply()}
#' 
## ------------------------------------------------------------------------
sapply(subiris, mean)

#' 
#' 여러 함수들은 옵션을 가지고 있다. 예를 들어 \texttt{mean()} 함수는 trim=, \texttt{na.rm=} 등의 옵션을 가지고 있다. 이런 옵션을 적용시키기 위해서는 \texttt{mean} 다음의 인자로 제시하면 된다.
## ------------------------------------------------------------------------
sapply(subiris, mean, trim=0.5)

#' 
#' 
#' 이와 비슷한 함수로 \texttt{lapply()}함수, \texttt{mapply()}함수 등이 있다. 여러 개를 헷갈리게 아는 것보다 하나를 확실하게 아는 것이 좋다. 개인적인 생각에 \texttt{sapply()}와 다음에 소개할 \texttt{tapply()}정도 확실하게 이해하는 것이 좋다고 본다.
#' 
#' \index{R!lapply()}
#' \index{R!mapply()} 
#' 
#' \texttt{tapply()함수}는 개략적으로 다음과 같이 사용한다.
#' \index{R!tapply()}
#' 
#' \begin{verbatim}
#' tapply(숫자형 vector, factor형 vector, 적용할 함수 )
#' \end{verbatim}
#' 
#' 즉, 어떤 값을 어떤 카테고리별로 나누어서, 나눈 대상별로 함수를 적용한 값을 돌려준다. \texttt{iris} 데이터셋에서 \texttt{Sepal.Lenghth}를  \texttt{Species}에 따라 평균이 어떻게 다른 지는 다음과 같이 구한다.
#' 
## ------------------------------------------------------------------------
tapply(iris$Sepal.Length, iris$Species, mean)

#' 
#' 결과를 하나의 표로 상상한다면, 행에는 맨 처음 나오는 숫자형 벡터의 이름이고, 열에는 팩터의 레벨이다. 즉, \texttt{Sepal.Lenght}가 \texttt{Species}의 level 들, setosa, versicolor, virginica에 따라 그 평균값을 구한다. 
#' 
#' \subsection*{plyr package를 이용한 Split-Apply-Combine 전략}
#' 
#' 언젠가 인터넷을 통해서 해들리 위컴 교수가  \texttt{pylr} 패키지에서 어떤 함수를 가장 많이 사용하는 지에 대한 설문이 있었는데, \texttt{ddply()} 함수가 압도적으로 많았다. 여기서 앞의  d는 input으로서의 데이터프레임을 말하고, 뒤의 d는 output으로서의 데이터프레임을 말한다. 즉,  데이터 프레임을 받아서, 정리한 다음, 데이터 프레임 형태로 돌려주는 것이다. 먼저 \texttt{ddply()}함수에 대해서 자세히 살펴보자. 우선 앞서 사용했던 \texttt{iris} 데이터를 이용해 본다.
#' 
#' \texttt{ddply()} 함수는 개략적으로 다음과 같이 이용한다.
#' \index{plry 패키지!ddply()}
#' 
#' \begin{kframe}\footnotesize
#' \begin{verbatim}
#' ddply(데이터프레임, .(팩터), 함수)
#' ddply(데이터프레임, .(팩터), A함수, A함수의 인자로 쓰일 함수들)
#' \end{verbatim}
#' \end{kframe}
#' 
#' 데이터셋을 팩터에 따라 나누고, 그 나눠진 서브그룹에 대하여 함수를 적용한 다음, 그 결과를 한꺼번에 정리해서 보여 주는 기능을 한다.
#' 
#' \texttt{ddply()} 함수의 작동 원리는 다음 그림에으로 설명해 보았다.\\
#' 
#' {\centering\includegraphics[scale=.30]{/Users/koseokbum/Dropbox/winImages/ddplyact.png}%
#' \outfigcaption{ddply() 함수의 작동 원리}\label{fig:ddplyact}}
#' 
#' 사용법을 하나씩 따라가 보자. 먼저 패키지를 로딩한다.
#' 
## ------------------------------------------------------------------------
library(plyr)

#' 
#' R에 내장된 \texttt{iris}라는 데이터셋을 이용해 설명한다. 일부의 데이터셋의 구조는 다음과 같다. 
#' 
## ----size="scriptsize"---------------------------------------------------
str(iris)

#' 
#' 어떤 Species가 몇 개씩 있는지를 알아보려면 다음과 같이 할 수 있다. \texttt{nrow()} 함수는 데이터 프레임의 행의 갯수를 알려주는 함수이다. 다음과 같이 하면 iris라는 데이터셋이 Species라는 팩터에 따라, 이 팩터가 3개의 레벨을 가지기 때문에 3개의 데이터셋으로 나눠진 다음, 그 나눠진 데이터셋에 \texttt{nrow()} 함수를 적용할 결과를 모아서 결과를 출력한다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), nrow)
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), nrow)

#' 
#' 이 경우도 같다. 세개의 작은 데이터셋으로 나눠진 다음 \texttt{dim()} 함수가 적용된 결과를 모아서 결과를 출력한다. 위와 다른 부분은 이 함수는 결과값이 2개를 되돌리는 함수라는 점이다. 이런 경우도 문제가 없다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), dim)
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), dim)

#' 
#' 위와 같이 하나의 함수가 여러 값을 되돌리는 경우도 되지만, 아래와 같이 하나의 값들을 되돌려 주는 함수를 벡터로 모았을 때도 작동한다. 
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), c(nrow, ncol))
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), c(nrow, ncol))

#' 
#' \texttt{ddply()} 함수에 세번째 인자로 들어가는 함수는 위와 같이 여러 함수가 들어갈 수 있다. 심지어 사용자가 만든 함수도 들어갈 수 있고, 심지어 그 위치에서 사용자 함수를 정의하면서도 사용할 수 있다. 그러나, 한 가지 제한이 있다. 세번째 인자로 들어가는 함수는 반드시 쪼개지는 데이터셋을 인자로 받을 수 있는 함수라야 한다는 점이다. \texttt{ddply()} 함수는 데이터 프레임을 받아서, 데이터가 정리된 형태로 데이터 프레임을 반환하는 함수이다. 그래서 이름이 dd로 시작하는 것이다. \texttt{ddply()} 함수는 데이터 프레임으로 된 큰 데이터셋을 받아서 작은 데이터셋으로 팩터 변수를 이용하여 쪼갠다. 이 작은 데이터셋 역시 데이터 프레임이다. 이 작은 데이터셋에 함수가 적용되어야 한다. 즉, 함수는 데이터 프레임을 인자로 받을 수 있어야 한다. 작은 데이터 프레임에 함수가 적용되어 결과를 반환하면 그것을 결합하여 원하는 결과로 반환한다. 
#' 
#' 
#' 위 사례에서 보면 \texttt{nrow(), dim(), ncol()} 함수 모두 데이터 프레임을 인자로 받을 수 있는 함수들인 것이다. 만약에 벡터를 인자로 받는 함수를 사용하기 위해서는 어떻게 해야할 지에 대해서 알아보자. 예를 들어 대표적인 평균을 계산하는 \texttt{mean()} 함수를 사용하여 iris 데이터셋에서 Species에 따른 평균값을 정리한 데이터 프레임을 얻을 필요가 있을 수 있다. 이런 경우는 함수를 새로 만들어 쓴다. 다음과 같이 할 수 있다.\\
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), function(df) {mean(df$Sepal.Length)})
#' \end{lstlisting}
#' 
#' 위에서 다음 부분이 사용자 정의 함수이다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' function(df) {mean(df$Sepal.Length)}
#' \end{lstlisting}
#' 
#' 이 함수에서 df는 임의의 객체이다. 즉, x라고 해도 되고, y라고 바꿔도 문제가 없다. 이 함수는 앞에서 쪼개진 데이터 프레임이라는 의미에서 df라고 이름을 준 것 뿐이다. 이렇게 하면 그룹에 따른 평균을 구할 수 있다. 결과는 다음과 같다. 
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), function(df) {mean(df$Sepal.Length)})

#' 
#' 그런데, 매번 이런 식으로 사용자 정의함수를 만들어야 한다면 불편할 것이다. 그래서 plyr 패키지에는 이런 불편을 덜어 주기 위해서 \textbf{\texttt{summarise()}} 라는 함수를 제공하고 있다. 먼저 \texttt{summarise}()라는 함수를 단독으로 사용했을 때 행동을 관찰해 보자. 기본 사용법은 다음과 같이 간단하다. 
#' 
#' \begin{lstlisting}[caption=summarise() 함수 사용법]
#' summarise( data, var= value, ...)
#' \end{lstlisting}
#' 
#' 그리고, 사용하는 예를 보면 다음과 같다. \texttt{baseball}이라는 데이터 프레임은 \texttt{plyr} 패키지에 포함되어 있어서, \texttt{plyr} 패키지를 로딩하면 자연적으로 같이 사용할 수 있는 데이터셋이다.
#' 
#' \begin{lstlisting}[caption=summarise() 함수 사용예, numbers=none]
#' summarise(baseball, duration = max(year) - min(year), nteams = length(unique(team)))
#' \end{lstlisting} 
#' 
#' \index{plyr 패키지!summarise()}
## ----echo=FALSE----------------------------------------------------------
summarise(baseball,
 duration = max(year) - min(year),
 nteams = length(unique(team)))

#' 
#' 즉, \texttt{summarise()} 함수는 데이터셋을 받아서, 데이터셋에 포함된 변수들을 사용하여 계산을 한 다음 이 값에 이름을 붙혀서 이것을 같은 데이터 프레임으로 돌려 주고 있다.  그리고, 이 계산을 할 때는 다른 함수들을 사용할 수 있다. 따라서, 이러한 행동은 \texttt{ddply()} 함수에서 사용할 수 있는 충분한 조건을 갖추고 있다. 물론 이 함수는 이런 용도로 저자가 만들었다고 볼 수 있다. 이 함수를 이용하면 위에서 본 것처럼 계산된 값을 V1 등과 같은 이름이 아닌 원하는 형태로 이름을 붙혀서 결과를 도출할 수 있다. iris 데이터셋에서 Species에 따른 \texttt{Sepal.Width}의 평균은 구해 보자. 
#' 
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width))
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width))

#' 
#' 위의 \texttt{summarise()} 함수의 사용 예에서 보았지만, 뒷따라 오는 변수들의 갯수에는 한정이 없다. 따라서, 한꺼번에 여러 가지가 정리된 데이터를 얻을 수 있다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width), sdSW=sd(Sepal.Width))
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width), sdSW=sd(Sepal.Width))

#' 
#' 즉, iris 데이터셋을 Species라는 팩터에 의해서 여러 그룹으로 나눈 다음, 각 그룹별 \texttt{Sepal.Width}의 평균과 표준편차를 구한 것이다. 이처럼  원한다면 무한히 확장시킬 수 있어, 여러 변수에 대한 데이터 정리를 한 줄의 코드로 끝내 버릴 수 있다.
#' 
#' 이제 \texttt{plyr} 패키지에서 제공하는 \textbf{\texttt{colwise()}} 라는 함수에 대해서 살펴보자. \texttt{summarise()} 함수는 데이터셋에 포함된 하나의 변수에 대한 어떤 계산을 처리한다. 물론 이런 것들을 하나씩 추가하여 작업할 수는 있기는 하다. 위의 예에서 \texttt{Sepal.Length}에 대한 평균까지 계산하려면 다음과 같이 해야 한다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), summarise, meanSW=mean(Sepal.Width), meanSL=mean(Sepal.Length))
#' \end{lstlisting}
#' 
#' 이런 식으로 작업하는 것은 \texttt{mean()} 함수를 중복하여 사용하는 것으로 변수의 갯수가 많아지면 매우 불편할 것이다. 이런 경우 \texttt{summarise()} 함수 대신에 \texttt{colwise()} 함수를 사용한다. 이 함수를 이용하면 복수의 열에 대해서 한꺼번에 함수를 적용시킬 수 있다. 이 때 계산에 포함되는 열들도 선택할 수 있다. 그런데, 약간 이해를 어렵게 만들 수 있는 부분은 \texttt{colwise()} 함수는 값을 반환하는 함수가 아니라, 함수를 반환한다는 점이다. 먼저, 이 부분부터 이해하고 넘어갈 필요가 있다. 예를 들어 다음과 같은 코드와 결과를 보자.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' colwise(mean, is.numeric)(iris)
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
colwise(mean, is.numeric)(iris)

#' 
#' 
#' 위에서 다음 부분, \\
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' colwise(mean, is.numeric)
#' \end{lstlisting}
#' 
#' 이 하나의 함수라는 것을 이해할 필요가 없다. 이 함수는 어떤 데이터 프레임이 있을 때, numeric 이라는 데이터 타입을 가진 열에 대해서만 \texttt{mean()} 이라는 함수가 적용되는 함수가 된다. 그래서 여기에 (iris)를 붙혀주면 iris라는 데이터 셋에서 numeric 이라는 데이터 타입을 가진 열에 대해서 \texttt{mean()} 함수가 적용되는 것이다. 
#' 
#' 앞선 예에서는 \texttt{is.numeric()} 함수를 사용하여 데이터셋에 있는 열을 구분했지만, 이런 조건을 이용하지 않고, 직접 변수 이름을 지정할 수도 있다. 예를 들어, \texttt{Sepal.Width, Sepal.Length, Petal.Width}에 대한 평균을 구할 때는 다음과 같이 하면 된다. 변수를 주는 방법은 조금 다르지만 같은 결과를 만든다.\\
#' 
#' 
#' \begin{lstlisting}[caption=]
#' colwise(mean, .(Sepal.Width, Sepal.Length, Petal.Width))(iris)
#' colwise(mean, c("Sepal.Width", "Sepal.Length", "Petal.Width"))(iris)
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
colwise(mean, .(Sepal.Width, Sepal.Length, Petal.Width))(iris)
colwise(mean, c("Sepal.Width", "Sepal.Length", "Petal.Width"))(iris)

#' 
#' 이제 이 함수를 \texttt{ddply()} 함수와 같이 사용해 보자.  \\
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), colwise(mean, is.numeric) )
#' \end{lstlisting}
#' 
## ----echo=FALSE, size='small'--------------------------------------------
ddply(iris, .(Species), colwise(mean, is.numeric) )

#' 
#' 이와 같이 하면 iris라는 데이터 프레임으로 된 데이터셋이 Species라는 팩터에 의해서 여러 서브그룹으로 쪼개진다. 이 쪼개진 데이터셋이 \texttt{colwise(mean, is.numeric)}이라는 함수로 넘겨지는 것이다. 앞에서 \texttt{colwise(mean, is.numeric)}은 통째로 하나의 함수라고 언급했다. 이 함수가 쪼개진 데이터셋에 적용된 결과들이 결합되어 최종 결과물을 만들어 내는 것이다. 마찬가지로, 위에서 같이 \texttt{Sepal.Length, Sepal.Width, Petal.Width}에 대한 평균만을 계산하고자 한다면 다음과 같이 한다.\\
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(iris, .(Species), colwise(mean, c("Sepal.Length", "Sepal.Width", "Petal.Width")))
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(iris, .(Species), colwise(mean, c("Sepal.Length", "Sepal.Width", "Petal.Width")))

#' 
#' 지금까지는 \texttt{ddply()} 함수에서 적용될 함수에 대해 알아보았다. 간과했던 것은 \texttt{ddply()} 함수의 두 번째 인자이다. 두 번재 인자는 보통 팩터가 들어가는데, 이 경우도 하나의 팩터 변수만을 쓸 수 있는 것은 아니다. 복수의 인자가 설정되면, 이들의 조합으로 데이터가 쪼개진다. 이 장에서 다루고 있는 \texttt{reshape}, \texttt{plyr} 패키지는 모두 Hadley Wickham이라는 사람이 만든 것이다. 같은 저자가 만든 ggplot2는 많은 사람들이 사랑하는 패키지 중의 하나이다. 이 패키지에 있는 \texttt{diamonds}라는 데이터 셋을 이용해 보려 한다.
#' 
## ----size='footnotesize'-------------------------------------------------
library(ggplot2)
str(diamonds)

#' 
#' 위 결과에서 보듯이 \texttt{diamonds}는 \Sexpr{nrow(diamonds)}개의 관찰값을 가진 작지 않은 데이터셋이다. 이 데이터셋에서 팩터형 변수를 이용하여 앞에서 설명한 \texttt{ddply()} 함수를 이용하여 데이터를 정리해 본다. 먼저 \texttt{cut}이라는 팩터에 따라 평균 가격이 어떠한지를 살펴 본다.\\
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(diamonds, .(cut), summarise, meanPrice=mean(price))
#' \end{lstlisting}
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(diamonds, .(cut), summarise, meanPrice=mean(price))

#' 
#' 다음은 cut과 color로 조합하여 데이터를 세분하여 계산한 것이다.
#' 
#' \begin{lstlisting}[caption=, numbers=none]
#' ddply(diamonds, .(cut, color), summarise, meanPrice=mean(price))
#' \end{lstlisting}
#' 
#' 
## ----echo=FALSE----------------------------------------------------------
ddply(diamonds, .(cut, color), summarise, meanPrice=mean(price))

#' 
#' 결과를 보면 \texttt{cut}이 5개의 레벨이 있고, \texttt{color}가 7개의 레벌에 있어 이들을 조합한 결과가 35개이므로 데이터가 35개의 그룹으로 쪼개져서 계산된다.
#' 
#' 
#' \section{두 데이터프레임의 결합}
#' 
#' 
#' 앞의 타이디 데이터 이론에서 하나의 표에는 하나의 관찰타입을 사용하는 것이 원칙이라고 했다. 가끔 엑셀 파일로 정리한 데이터셋을 보면 좌우로 너무 길어서 한 눈에 파악하기 어려운 경우들이 있는데, 대부분 이 원칙을 지키지 않기 때문에 나타나는 현상이다. 그리고, 그렇게 데이터를 정리하게 되는 이유는 데이터를 여러 개의 표로 나눠졌을 때, 이들을 결합하는 방법에 익숙하지 않기 때문일 것이라는 생각을 한다. 여기서는 plyr 패키지에 포함되어 있는 \texttt{join()} 함수를 가지고 데이터 프레임을 결합하는 방법에 대해서 살펴 보려 한다. 
#' 
#' \index{plry 패키지!join()}
#' 
#' 예를 사용한 데이터 프레임 3개를 준비했다. 
#' 
#' \begin{itemize}
#'   \item Student: 학생의 이름(StudentName)과 학번(StudentId)을 담은 데이터 프레임
#'   \item SubjectA: A 과목을 들은 학생들의 Id와 학점(gradeA)
#'   \item SubjectB: B 과목을 들은 학생들의 Id와 학점(gradeB)
#' \end{itemize}
#' 
## ----echo=TRUE, size='small'---------------------------------------------
StudentName <- c("가", "나", "다", "라", "마")
StudentId <- 111:115
Student <- data.frame(StudentName , StudentId)
gradeA <- c("a","a","b")
SubjectA <- data.frame(StudentId=c(111, 113, 115), gradeA)
gradeB <- c("a","c","a","d")
SubjectB <- data.frame(StudentId=c(111, 112, 114, 115), gradeB)

#' 
#' 이렇게 준비된 데이터 프레임은 다음과 같다.
## ------------------------------------------------------------------------
Student
SubjectA
SubjectB

#' 
#' Student는 학교 당국에서 관리하는 자료이고, SubjectA는 A 학과에서 관리하는 자료이고, SubjectB는 B 학과에서 관리하는 자료라고 생각해도 괜찮다. 이 세개의 데이터 프레임은 서로 독립된 자료이면서 StudentId라는 변수를 통해 서로 연관된 정보를 가지고 있다. 이 개의 데이터 프레임을 서로 결합하여 새로운 정보를 담은 데이터 프레임을 만들어 본다. 베이스 R에도 merge()라는 함수가 있기는 하지만, 여기서는 plyr 패키지의 \texttt{join()} 함수를 가지고 설명한다. \texttt{join()} 함수가 데이터가 커졌을 때, 효율적으로 결합하는 것으로 알려져 있다. 
#' 
#' 흔히 관계형 데이터베이스를 다룰 때 자주 접하게 되는 용어인데, 결합하는 방식에 관한 것으로 left join, right join 등과 같은 말을 쓴다. 이런 것들이 무슨 의미인지 알아보자. \texttt{join()} 함수에는 type= 이라는 옵션에서 이들을 결합할 수 있다. 여기서 왼쪽, 오른쪽은 합치게 될 데이터를 앞에 두었을 때 왼쪽에 있는 것, 오른쪽에 있는 것이라는 의미이다. 
#' 
#' \begin{itemize}
#'   \item \texttt{'left'}: 왼쪽에 있는 모든 행을 포함하고, 오른쪽에는 매칭되는 열만을 포함한다.
#'   \item \texttt{'right'}: 오른쪽에 있는 모든 행을 포함하고, 왼쪽에는서는 매칭되는 열만을 포함한다.
#'   \item \texttt{'inner'}: 왼쪽과 오른쪽 모두에서 매칭되는 행만 포함한다.
#'   \item \texttt{'full'}: 오른쪽과 매칭되는 모든 왼쪽의 행과 더불어 왼쪽과 매칭되지 않는 오른쪽의 행을 모두 포함한다.
#' \end{itemize}
#' 
#' 말로 해서는 잘 이해가 되지 않을 수 있는데, 예를 보면서 살펴보자. 먼저 left join, right join부터 살펴보자. \texttt{join()} 함수는 by= 라는 옵션을 가지고 있는데, 만약 쓰지 않으면, 이름이 같은 열을 기준으로 한다. 
#' 
## ------------------------------------------------------------------------
join(Student, SubjectA, type='left')
join(SubjectA, Student, type='left')
join(SubjectA, Student, type='right')

#' 
#' Student와 SujbectA를 left join 방식으로 결합하는 예를 보면 Student의 모든 행을 가지고 있으면서, StudentId를 가지고 결합하고 있기 때문에 이 값이 서로 매칭되는 것을 가지고 gradeA 열을 만든다. 이것은 SubjectA와 Student를 right join한 결과와 같다. 열의 순서만 달라지는 것이다. 
#' 
#' 두 번째 SubjectA와 Student를 left join한 결과는 SubjectA의 모든 행이 들어가고, StudentId의 값을 비교하여 같은 값에 대해서 Student의 열인 StudentName을 추가한다. 
#' 
#' 
#' 다음은 inner join이다. inner join은 교집합과 같은 개념이다. 
#' 
## ------------------------------------------------------------------------
join(SubjectA, SubjectB, type='inner')

#' 
#' 이 경우 StudentId 중에서 공유하는 값에 대한 정보만 서로 결합한다.
#' 
#' 다음은 full join이다. full join은 합집합과 같은 개념이다.
#' 
## ------------------------------------------------------------------------
join(SubjectA, SubjectB, type='full')

#' 
#' 이러한 원칙을 가지고 앞의 데이터 프레임을 결합하여 보자. 학교 당국에서 학생별 학점 리스트를 만든다고 하면 다음과 같이 하면 될 것이다.
#' 
## ------------------------------------------------------------------------
df1 <-join(Student, SubjectA, type='left')
df <- join(df1, SubjectB, type='left')
df

#' 
#' A 학과에서 수강하는 학생들의 이름을 알고 싶다면 다음과 같이 한다. 
#' 
## ------------------------------------------------------------------------
st <- join(SubjectA, Student, type='left')
st

#' 
#' \texttt{join()} 함수는 디폴트로 결합될 때 같은 이름의 변수를 매개 변수로 사용한다. 이름이 다르거나, 결합의 기준을 명확히 해 주고 싶은 경우에는 \texttt{by=} 라는 옵션을 사용한다.
#' 
## ------------------------------------------------------------------------
st <- join(SubjectA, Student, by="StudentId", type='left')
st

#' 
#' \section{dplyr 패키지}
#' \index{dplyr 패키지!관련 장절}
#' 
#' \texttt{dplyr} 패키지(\cite{dplyr})는 비교적 최근에 발표되었는데, 기존의 \texttt{dplyr} 패키지보다 빠르고, 그 논리를 이해하기가 쉽고, 함수들을 체인으로 연결시켜서 작업할 수 있는 등의 장점을 가지고 있다. 이 패키지는 관계형 데이터베이스의 테이블에 있는 자료들도 읽을 수 있는 기능이 있으나 이 절에서 소개하지는 않는다. 관련된 비니에트(\texttt{>vigette("databases"})를 읽어보면 이해하기 어렵지 않을 것이다. 
#' 
#' 이 \texttt{dplyr} 패키지를 적절히 사용하면 비교적 큰 데이터를 원하는 형태로 변환하거나, 이해하기 편하게 정리하는 등이 일들을 손쉽게 할 수 있을 것이다. \texttt{dplyr} 패키지의 특징을 먼저 살펴보면 다음과 같다. 
#' 
#' \begin{itemize}
#'   \item 크기가 큰 데이터를 R 콘솔 등에서 출력할 때 출력하는 시간이 오래 걸리고, 콘솔이 데이터로 넘쳐나는 현상이 벌어지는데, 비교적 간단한 형태로 보여주는 함수가 있다.
#'   \item 데이터를 다루는 데 기본이 되는 5 가지 함수가 있어서, 이들을 적절히 조합하여 사용하면 원하는 형태로 데이터를 변환할 수 있고, 정리할 수 있다. 또한 이런 과정들을 체인으로 묶어서 코딩을 할 수 있어서 굳이 중간에 임시 변수들을 만들지 않고도 작업할 수 있다. 
#'   \item 앞에서 소개한 plyr 패키지가 split-apply-combine이라는 논리로 만들어져 있다고 했는데, 이들 과정이 함수 안에서 숨겨져 있어서 처음에는 확 눈에 띄지 않아서 이해하기가 어렵다. dplyr 패키지에서는 이런 과정을 투명하게 진행할 수 있어서 매우 편리하다. 
#' \end{itemize}
#' 
#' \subsection{큰 데이터의 출력을 손쉽게 하기}
#' 
#' \texttt{dplyr} 패키지의 \texttt{tbl\_df()} 함수는 큰 데이터프레임을 보기 쉬운 형태로 바꿔준다. 필요한 경우에는 언제든지 \texttt{as.data.frame()} 함수를 사용하여 원래의 형태로 바꿔준다. 아래에서 ggplot2 패키지를 사용한 것은 패키지에 포함된 diamonds 패키지를 사용하기 위해서이다.
#' 
#' \index{dplyr 패키지!tbl\_df()}
#' 
## ----warning=FALSE, error=FALSE, message=FALSE---------------------------
library(dplyr)
library(ggplot2)
diamonds_df <- tbl_df(diamonds)
diamonds_df

#' 
#' \subsection{데이터를 다루는 데 기본이 되는 5 가지 함수}
#' dply 패키지에서는 데이터를 다루는 데 기본이 되는 5 가지 함수들이 있다. 이들을 적절히 조합하여 사용하면 원하는 형태로 데이터를 변환하거나 원하는 형태로 정리할 수 있다. 먼저, 알아둘 사항은 이들 함수는 데이터프레임 혹은 위에서 \texttt{tbl\_df()} 함수로 변환된 데이터프레임을 받아서 데이터프레임을 반환한다는 점이다. 
#' 
#' \index{dplyr 패키지!5가지 동사}
#' 
#' \begin{itemize}
#'   \item 조건에 맞는 행\mysub{rows}을 골라내기: filter()
#'   \item 필요한 변수(열)만 골라내기: select()
#'   \item 정렬하기: \texttt{arrange()}
#'   \item 기존의 변수(열)을 가지고 계산하여 새로운 변수를 생성하기: \texttt{mutate()}
#'   \item 기존의 변수를 가지고 계산하여 하나의 값으로 내놓기: summarise()
#' \end{itemize}
#' 
#' 
#' plyr 패키지에서 전체 데이터프레임은 어떤 기준으로 나누는 역할은 \texttt{group\_by()} 함수가 하게 되는데, 이것에 대해서는 이후에 다룬다. 앞에서 만들어 놓은 \texttt{diamonds\_df} 데이터프레임을 가지고 함수의 사용법을 소개한다. 
#' 
#' \index{dplyr!group\_by()}
#' 
#' 먼저 \texttt{filter()} 함수는 엑셀의 필터 기능과 매우 유사하다. 조건을 주고, 조건을 만족하는 모든 행을 골라내는 역할을 한다. 쉼표(,)는 논리적 AND를 의미하며, R에서 사용하는 일반적인 논리 표현식을 모두 사용할 수 있다. \texttt{diamonds\_df} 데이터프레임에서 cut이 Premium이고(AND) color가 E인 데이터프레임을 추출하고자 한다.
#' 
#' \index{dplyr!filter()}
## ------------------------------------------------------------------------
filter(diamonds_df, cut == "Premium", color=="E")

#' 
#' 만약 cut의 Premium이거나(OR)  color가 E인 데이터프레임을 추출하고자 하는 경우는 다음과 같이 한다. 
## ------------------------------------------------------------------------
filter(diamonds_df, cut == "Premium" | color == "E")

#' 
#' \texttt{select()} 함수는 필요한 열을 골라낸다. 앞의 데이터프레임에서 cut, color 열만을 선택하려고 하면 다음과 같이 한다. 
#' \index{dplyr 패키지!select()}
#' 
## ------------------------------------------------------------------------
select(diamonds_df, cut, color)

#' 
#' 열의 이름을 사용하는데, \texttt{names()} 함수를 적용하여 나오는 순서를 가지고 콜론(:) 연산자를 사용하여 필요한 열을 지정할 수 있다. \texttt{diamonds\_df}의 x에서 z까지의 열만을 골라내기 위해서는 다음과 같이 한다.
#' 
## ------------------------------------------------------------------------
select(diamonds_df, x:z)

#' 
#' 또는 연산자 -(빼기) 기호를 사용하여 어떤 열이나 열들을 제외할 수도 있다. x에서 z까지 열을 제외하고자 한다면 다음과 같이 한다. 
#' 
## ------------------------------------------------------------------------
select(diamonds_df, -(x:z))

#' 
#' 열의 이름이 아닌 인덱스(위치)를 가지고 선택할 수도 있다.
#' 
## ------------------------------------------------------------------------
select(diamonds_df, -(4:7))

#' 
#' 포함시키고자 하는 열들의 이름을 벡터로 주거나, 인덱스 값을 벡터로 주면 해당 되는 열들을 선택할 수 있다.
#' 
## ------------------------------------------------------------------------
select(diamonds_df, c(carat, price, x, y))
select(diamonds_df, c(1,7, 8, 9))

#' 
#' 데이터를 정렬하기 위해서는 \texttt{arrange()} 함수를 사용하는데, 정렬의 기준을 삼을 열의 이름이나 열의 이를들의 벡터를 정해주면 된다.
#' 
#' \index{dplyr 패키지!arrange()}
## ------------------------------------------------------------------------
arrange(diamonds_df, price, carat)

#' 
#' 위의 결과들을 보면 먼저 price를 오름차순으로 하고, price가 같은 경우에는 carat을 오름차순으로 하여 데이터들이 정렬되는 것을 볼 수 있다. 만약 내림차순으로 하고 싶으면 \texttt{desc()} 함수를 사용한다. 
#' 
## ------------------------------------------------------------------------
arrange(diamonds_df, desc(price))

#' 
#' \texttt{mutate()} 함수는 기존의 열의 값을 가지고 어떤 계산을 한 다음에 필요한 열을 추가할 때 사용한다. 의미는 없지만, \texttt{diamonds\_df} 데이터에서 x, y, z 값을 합한 값을 d라른 열을 만든다고 하면 다음과 같이 한다. 
## ------------------------------------------------------------------------
mutate(diamonds_df, d = x + y + z)

#' 
#' \index{dplyr 패키지!mutate()}
#' 
#' \texttt{summarise()} 함수는 기본적으로 \texttt{plyr} 패키지의 기능과 동일한데, 이 함수는 주로는 뒤에서 다룰 \texttt{group\_by()} 함수와 사용할 때 강력한 기능을 제공한다. 잠깐만 살펴보자. 예를 들어 \texttt{diamonds\_df}의 x, y 값을 사용하여 단순히 그 평균들만 필요한 경우는 다음과 같이 할 수 있다.
#' 
## ------------------------------------------------------------------------
summarise(diamonds_df, xMean=mean(x), yMean=mean(y))

#' 
#' \subsubsection{데이터를 조건에 맞게 그룹으로 나누기}
#' 
#' \texttt{plyr} 패키지에 \texttt{ddply()} 함수는 내부적으로 정해진 열의 레벨 값을 가지고 데이터를 나누고, 그룹별로 어떤 계산을 하여 결과를 만들 수 있다. 예를 들어서 diamonds 데이터셋에서 cut에 따라 그룹화하여 그룹별로 price의 평균을 계산한다면 다음과 같이 한다. 
#' 
## ------------------------------------------------------------------------
library(plyr)
ddply(diamonds, .(cut), summarise, priceMean=mean(price))

#' 
#' 이 경우 \texttt{ddply()} 함수의 행동을 잘 이해하는 경우에는 문제가 덜 되지만, 그림 \ref{fig:ddplyact}에서 설명한 바와 같이 그 원리에 대한 이해가 필요하다. \texttt{dplyr} 패키지에서는 이것을 투명하게 사용할 수 있도록 \texttt{group\_by()}라는 함수를 명시적으로 사용할 수 있게 했다. 
#' 
#' \texttt{group\_by()} 함수로 그룹핑을 명시적으로 지정할 수 있다. 예를 들어 위에서와 같이 cut을 기준으로 그룹화한다면 다음과 같이 한다. 
#' \index{dplyr 패키지!group\_by()}
#' 
## ------------------------------------------------------------------------
df <- group_by(diamonds_df, cut)
df

#' 출력된 결과를 보면 두 번째 줄에서 \texttt{Group: cut}에서 명시하고 있음을 볼 수 있고, 데이터프레임의 내용 자체는 원래의 데이터프레임과 별 차이가 없다. 이 결과를 가지고 앞에서와 같이 \texttt{summarise()} 함수를 사용하여 price의 평균을 구해보면 다음과 같다.
#' 
## ------------------------------------------------------------------------
summarise(df, meanPrice = mean(price, na.rm=TRUE))

#' 
#' dply 패키지는 또한 \texttt{summarise()} 함수와 함께 사용할 수 있는 유용한 함수들을 제공한다. \texttt{n()} 함수는 그룹별로 관찰값들의 개수를 반환한다.
#' 
## ------------------------------------------------------------------------
summarise(df, N = n(), meanPrice = mean(price))

#' 
#' \texttt{n\_distinct(x)} 함수는 x의 유일한\mysub{unique} 값의 개수를 반환하고, \texttt{first(x), last(x), nth(x, n)}는 각각 처음, 마지막, n번째 값을 반환한다. 
#' 
#' 
#' \subsubsection{함수들의 체인}
#' \index{dplyr 패키지!함수 체인}
#' 
#' 앞에서 설명한 5 가지 데이터 조작용 함수들과 \texttt{group\_by()} 함수들은 체인으로 연결시켜 사용할 수 있다. 이것은 유닉스 등에서 사용하는 파이프(|) 기능과도 비슷하다. 기본적으로 이들 함수들을 체인으로 연결시킬 수 있는 것을 이들 함수들이 데이터프레임을 받아서 데이터프레임을 반환하기 때문에 가능하다. 체인으로 묶는 연산자는 \texttt{\%.\%} 이다. 
#' 
#' 만약 diamonds 데이터셋으로 다음과 같은 과정을 한다고 생각해 보자. (1) carat이 1 보다 크고, 1.5 보다 작은 데이터셋으로 한정하고, (2) 결과를 color에 따라 나눠서, (3) 그룹별로 price  평균을 구하고, (4) 이 결과를 price를 기준으로 내림차순으로 정리하는 과정이다. 
#' 
## ------------------------------------------------------------------------
tmp <- filter(diamonds_df, carat > 1, carat<1.5)
tmp <- group_by(tmp,  color)
tmp <- summarise(tmp, price=mean(price))
result <- arrange(tmp, desc(price))
result

#' 
#' 이 과정을 체인으로 묶으려면 우선 다루고자 하는 데이터셋부터 지정하고, 과정을 \texttt{\%.\%} 연산자자를 사용하여 연결한다. 
#' 
## ------------------------------------------------------------------------
diamonds_df %.%
  group_by(color) %.% 
  summarise(price=mean(price)) %.%
  arrange(desc(price))

#' 
#' 이렇게 하면 코딩과 데이터셋 정리과정을 깔끔하게 정리할 수 있어서 좋다. 
#' 
#' \subsubsection{윈도우 함수들과 다른 기능들}
#' 
#' \texttt{dplyr} 패키지에는 window functions이라는 이름으로 \texttt{row\_number(), min\_rank(), dense\_rank(), ntile(), lead(), lag()} 등과 같은 함수군들을 제공하고 있다. 위에서 살펴본 \texttt{summarise()} 함수가 여러 개의 값이 들어있는 벡터를 받아서 평균 등과 같이 하나의 값으로 정리되는 결과를 반환한다면 이들 함수군에서 사용하는 함수들을 벡터를 받아서 벡터를 반환한다는 점이 다르다. 이들 함수군에는 순위를 다루는 것이나, 앞선 데이터(lead), 뒤에 나오는 데이터(lag), 누적하면서 반복하는 등과 같은 기능들을 제공한다. 이와 같은 기능들을 시계열 자료 등을 다룰 때는 절대적으로 필요한다.
#' 
#' 또 \texttt{dplyr} 패키지에는 관계형 데이터베이스의 테이블에 있는 데이터를 읽을 수 있는 기능을 제공하고, 데이터베이스를 다룰 때 사용하는 쿼리를 R로 작성할 수도 있다.
#' 
#' 이러한 기능들을 패키지에 포함된 비니에트를 읽어보면 이해할 수 있을 것으로 보고, 여기서는 \texttt{\texttt{dplyr}} 패키지의 유용성을 살짝 소개하는 이 수준으로 정리하려 한다. 
#' 
