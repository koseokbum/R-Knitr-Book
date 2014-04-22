library(knitrBootstrap)
options(rstudio.markdownToHTML =
          function(inputFile, outputFile) {
            require(knitrBootstrap)
            knit_bootstrap_md(input=inputFile, output=outputFile)
            })