library(shiny)
library(shinydashboard)
library(DT)
library(caret)
library(tidyverse)
library(readr)
library(ggplot2)
library(rpart)
library(randomForest)
library(pROC)
library(ggcorrplot)

# Read the winequality data from a CSV file (replace 'path/to/winequality.csv' with the actual file path)
WineQuality <- read.csv("C:/Users/rsdek/Documents/repos/ShinyApps/rshiny-wine/WineQuality.csv")

# Server logic for the Shiny App
server <- function(input, output, session) {
  
  # About Page
  
  # Your server logic for the About page goes here
  
  # Data Exploration Page
  # One Variable Analysis
  output$oneVarSummaryOutput <- renderPrint({
    req(input$oneVarAnalysis, input$selectedOneVar)
    if (input$oneVarAnalysis) {
      if (input$oneVarSummary) {
        # Calculate the five-number summary of the selected variable
        summary_stats <- summary(WineQuality[, input$selectedOneVar])
        summary_stats
      } else {
        NULL
      }
    }
  })
  
  output$oneVarHistogramOutput <- renderPlot({
    req(input$oneVarAnalysis, input$selectedOneVar)
    if (input$oneVarAnalysis) {
      if (input$oneVarHistogram) {
        # Create a histogram of the selected variable
        ggplot(WineQuality, aes_string(x = input$selectedOneVar)) + geom_histogram(binwidth = 1) + labs(title = "Histogram")
      } else {
        NULL
      }
    }
  })
  
  # Two Variable Analysis
  observeEvent(input$analyzeTwoVar, {
    # Create an overlayed histogram of the selected variables
    if (input$twoVarScatterplot) {
      output$twoVarScatterplotOutput <- renderPlot({
        req(input$selectedTwoVar1, input$selectedTwoVar2)
        ggplot(WineQuality, aes_string(x = input$selectedTwoVar1, y = input$selectedTwoVar2)) +
          geom_point(alpha = 0.7) +
          labs(title = "Two-Variable Scatterplot")
      })
    } else {
      output$twoVarScatterplotOutput <- NULL
    }
    
    output$correlationOutput <- renderText({
      req(input$selectedTwoVar1, input$selectedTwoVar2)
      correlation <- cor(WineQuality[, input$selectedTwoVar1], WineQuality[, input$selectedTwoVar2])
      paste("Correlation Coefficient:", correlation)
    })
  })
  
  # Multivariable Analysis
  output$multiVarPCAOutput <- renderPlot({
    req(input$analyzeMultiVar, input$selectedMultiVar)
    if (input$analyzeMultiVar && input$multiVarPCA) {
      # Create PCA plot for selected variables
      pca_data <- WineQuality[, input$selectedMultiVar]
      pca_result <- prcomp(pca_data, scale. = TRUE)
      biplot(pca_result, choices = c(1, 2), scale = 0)
    }
  })
  
  output$multiVarCorrelationOutput <- renderPlot({
    req(input$analyzeMultiVar, input$selectedMultiVar)
    if (input$analyzeMultiVar && input$multiVarCorrelation) {
      # Create correlation heatmap for selected variables
      correlation_matrix <- cor(WineQuality[, input$selectedMultiVar])
      ggcorrplot::ggcorrplot(correlation_matrix, lab = TRUE, title = "Correlation Heatmap")
    }
  })
  

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
    
    # Check if predictors are selected
    if (length(predictors) == 0) {
      return(NULL)  # Return NULL if no predictors are selected
    }
    
    # Check if selected variables exist in the dataset
    if (any(!predictors %in% names(WineQuality))) {
      return(NULL)  # Return NULL if selected variables do not exist in the dataset
    }
    
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
    models <- fit_models()
    
    output$fitStats <- renderPrint({
      # Fit statistics for Generalized Linear Model
      if (!is.null(models$glm_model)) {
        # Predict on test data
        glm_pred <- predict(models$glm_model, newdata = test_data, type = "response")
        # Convert probabilities to binary outcome (0 or 1)
        glm_pred_class <- ifelse(glm_pred > 0.5, 1, 0)
        # Calculate RMSE
        glm_rmse <- sqrt(mean((test_data$Red - glm_pred)^2))
        cat("Generalized Linear Model RMSE:", glm_rmse, "\n")
      }
      
      # Fit statistics for Classification Tree
      if (!is.null(models$tree_model)) {
        # Predict on test data
        tree_pred <- predict(models$tree_model, newdata = test_data, type = "class")
        # Create confusion matrix
        tree_cm <- table(Actual = test_data$Red, Predicted = tree_pred)
        cat("Classification Tree Confusion Matrix:\n")
        print(tree_cm)
      }
    })
    
    output$varImpPlot <- renderPlot({
      # Plot variable importance for Random Forest
      if (!is.null(models$rf_model)) {
        varImpPlot(models$rf_model, main = "Random Forest Variable Importance")
      }
    })
  })
  
  # Compare models on the test set
  observeEvent(fit_models(), {
    # Evaluate the models on the test set and display appropriate fit statistics
  })
  
  #Data Page
  
  # Reactive values for the full data and subsetted data
  full_data <- reactiveVal(WineQuality)
  subsetted_data <- reactiveVal(NULL)
  
  # Render the data table
  output$dataTable <- renderDT({
    datatable(full_data())
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
  
  # Update the subsetted data based on the user's inputs
  observeEvent(input$applySubset, {
    req(input$nRows, input$columns)
    subset_data <- full_data()[1:min(input$nRows, nrow(full_data())), input$columns, drop = FALSE]
    subsetted_data(subset_data)
  })
  
  # Render the subsetted data table
  output$subsettedDataTable <- renderDT({
    datatable(subsetted_data())
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