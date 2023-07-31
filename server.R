#Server file 

library(shiny)
library(shinydashboard)
library(DT)
library(caret)
library(tidyverse)
library(readr)
library(ggplot2)
library(rpart)
library(randomForest)



# Read the winequality data from a CSV file (replace 'path/to/winequality.csv' with the actual file path)
WineQuality <- read.csv("C:/Users/rsdek/Documents/repos/ShinyApps/rshiny-wine/WineQuality.csv")

# Server logic for the Shiny App
server <- function(input, output, session) {
  
  # About Page
  
  # Your server logic for the About page goes here
  
  # Data Exploration Page
  
  # Your server logic for the Data Exploration page goes here
  
  # Modeling Page
  observeEvent(input$trainProp, {
    # Update the test proportion based on the selected train proportion
    updateNumericInput(session, "testProp",
                       value = 1 - input$trainProp,
                       min = 0,
                       max = (1 - input$trainProp),
                       step = 0.01
    )
  })
  
  observeEvent(input$testProp, {
    # Update the train proportion based on the selected test proportion
    updateNumericInput(session, "trainProp",
                       value = 1 - input$testProp,
                       min = 0,
                       max = (1 - input$testProp),
                       step = 0.01
    )
  })
  # Fit models on the training data
  fit_models <- eventReactive(input$fitModels, {
    # Split data into training and test sets
    train_index <- createDataPartition(WineQuality$Red, p = input$trainProp, list = FALSE)
    train_data <- WineQuality[train_index, ]
    test_data <- WineQuality[-train_index, ]
    
    # Prepare predictors and response variables
    predictors <- input$variables
    response_var <- "Red"
    
    # Fit the models
    models <- list()
    if (input$modelType == "Generalized Linear Model") {
      models$glm_model <- glm(as.formula(paste(response_var, "~", paste(predictors, collapse = "+"))),
                              data = train_data, family = binomial)
    } else if (input$modelType == "Classification Tree") {
      models$tree_model <- rpart(as.formula(paste(response_var, "~", paste(predictors, collapse = "+"))),
                                 data = train_data, method = "class")
    } else if (input$modelType == "Random Forest") {
      models$rf_model <- randomForest(as.formula(paste(response_var, "~", paste(predictors, collapse = "+"))),
                                      data = train_data, ntree = 100)
    }
    
    models
  })
  
  
  # Display model fit statistics and summaries
  observeEvent(fit_models(), {
    # Update your UI elements here to display model fit statistics and summaries
  })
  
  # Compare models on the test set
  observeEvent(fit_models(), {
    # Evaluate the models on the test set and display appropriate fit statistics
  })
  
  
  # Data Page
  output$dataTable <- renderDT({
    datatable(WineQuality)
  })
  
  # Allow the user to subset rows and columns
  output$subsetControls <- renderUI({
    fluidRow(
      column(width = 4,
             h4("Subset Rows"),
             # Numeric input to select the number of rows to display
             numericInput("nRows", "Number of Rows to Display:", 10, min = 1, max = nrow(WineQuality))
      ),
      column(width = 4,
             h4("Subset Columns"),
             # Select input to choose the columns to display
             selectInput("columns", "Select Columns to Display:", names(WineQuality), multiple = TRUE)
      ),
      column(width = 4,
             # Apply button to apply the row and column subset
             actionButton("applySubset", "Apply Subset")
      )
    )
  })
  
  # Reactive data for the subsetted data table
  subsetted_data <- reactive({
    req(input$applySubset)
    # Subset the data based on the user's inputs
    subset_data <- WineQuality[1:input$nRows, input$columns, drop = FALSE]
    subset_data
  })
  
  # Update the data table with the subsetted data
  observe({
    replaceData(proxy = dataTableProxy("dataTable"), data = subsetted_data())
  })
  
  # Download the whole or subsetted dataset as a CSV file
  output$downloadData <- downloadHandler(
    filename = function() {
      if (!is.null(input$applySubset) && input$applySubset > 0) {
        paste("subsetted_data.csv")
      } else {
        paste("WineQuality.csv")
      }
    },
    content = function(file) {
      if (!is.null(input$applySubset) && input$applySubset > 0) {
        write.csv(subsetted_data(), file, row.names = FALSE)
      } else {
        write.csv(WineQuality, file, row.names = FALSE)
      }
    }
  )
}
