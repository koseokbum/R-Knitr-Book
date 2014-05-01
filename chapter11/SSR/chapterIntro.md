## 실행하는 방법

이 사례는 `slidify` 웹 프레젠테이션을 만든다. 여기에 `shiny` 앱이 장착된 슬라이드를 삽입한다.

이런 슬라이드가 제목을 제외하고 2 개가 있는데, 

- 처음은 평범한 `shiny` 앱을 넣는 사례를 보여 준다.
- 다음은 `rCharts`를 사용하여 사용자 인터랙션 기능을 가진 `shiny` 앱을 넣는 사례를 넣었다.

실행은 다음과 같이 한다.

1. 
2. RStudio의 R 콘솔에서 다음과 같이 실행한다.

    ~~~~
    library(shiny)
    library(slidify)
    runDeck()
    ~~~~

**책의 오류**

책의 499쪽의 코드에서 `slidifyUI(`라는 부분 앞에 `rCharts` 패키지를 로딩하는 과정이 빠져있다.

따라서, 

~~~
library(rCharts)
slidifyUI(
  sidebarPanel(
  ....
~~~

과 같이 되어야 한다.





