---
title       : 월간 매출 보고서
subtitle    : 
author      : SBKo
job         : 
framework   : minimal       # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
ext_widgets : {rCharts: "libraries/morris"}
mode        : selfcontained # {standalone, draft}
---









2014년 1월부터 6월까지 매출은 다음과 같다.

|  month|   revenue|
|------:|---------:|
|      1|  75000000|
|      2|  72000000|
|      3|  81000000|
|      4|  83000000|
|      5|  83500000|
|      6|  86000000|


월 평균 80,083,333원의 매출이 있었다.



<div id = 'chart2' class = 'rChart morris'></div>
<script type='text/javascript'>
    var chartParams = {
 "element": "chart2",
"width":            800,
"height":            400,
"xkey": "month",
"ykeys": [
 "revenue" 
],
"data": [
 {
 "month":              1,
"revenue":       75000000 
},
{
 "month":              2,
"revenue":       72000000 
},
{
 "month":              3,
"revenue":       81000000 
},
{
 "month":              4,
"revenue":       83000000 
},
{
 "month":              5,
"revenue":       83500000 
},
{
 "month":              6,
"revenue":       86000000 
} 
],
"id": "chart2",
"labels": "revenue" 
},
      chartType = "Bar"
    new Morris[chartType](chartParams)
</script>



