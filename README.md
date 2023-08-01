# Red and White Wine Quality Shiny App 
## Description
This R Shiny app was created as a final project for the ST 558 (Data Science for Statisticians) course at North Carolina State University, instructed by Dr. Jason Osborne. The app explores and models red and white wine quality data pulled from the [UCI Machine Learning respository](https://archive.ics.uci.edu/dataset/186/wine+quality). The app views, explores, and models the combined (red and white) wine quality data with wine quality as the target variable of interest. A user can do their own exploratory data analyses and view three types of models (linear regression, regression decision tree, and random forest model) for whatever subset of variables they choose.
## Required Packages
The following packages must be installed in order for this app to Run.
- `shiny`
- `shinydashboard`
- `DT`
- `caret`
- `tidyverse`
- 'readr'
- `ggplot2`
- `rpart`
- `randomForest`
- `pROC`
- `ggcorrplot`
- `corrplot`
- `e1071 `
- `Metrics`
## Run this line of code to install packages 
The following line of code may be ran in your R Console or terminal; please run this in case you do not already have these packages. 
`install.packages(c("shiny","shinydashboard","DT","caret","tidyverse","readr","ggplot2","rpart","randomForest","pROC","ggcorrplot","corrplot","e1071","Metrics"))`
## shiny::runGitHub()
The following code can be pasted into RStudio console in order to run this app:
`shiny::runGitHub("rinadeka/rshiny-wine")`
