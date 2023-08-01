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
library(corrplot)
library(e1071)
library(Metrics)

# Read the winequality data from a CSV file
WineQuality <- read.csv("data/WineQuality.csv")

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
  
  
  model_fits <- eventReactive(input$fit_models, {
    
    if(length(input$model_vars) == 0) {
      return(NULL)
    }
    model_vars <- c(input$model_vars, input$dependent_var)
    
    # Split the data
    set.seed(123)  # for reproducibility
    train_indices <- sample(1:nrow(WineQuality), size = round(input$train_prop * nrow(WineQuality)))
    train_data <- WineQuality[train_indices, model_vars, drop = FALSE]
    test_data <- WineQuality[-train_indices, model_vars, drop = FALSE]
    
    # Fit the models
    # lin_reg <- lm(quality ~ ., data = train_data)
    # tree <- rpart(quality ~ ., data = train_data)
    # rf <- randomForest(quality ~ ., data = train_data)
    # Fit the models
    lin_reg <- lm(as.formula(paste(input$dependent_var, "~ .")), data = train_data)
    tree <- rpart(as.formula(paste(input$dependent_var, "~ .")), data = train_data)
    rf <- randomForest(as.formula(paste(input$dependent_var, "~ .")), data = train_data)
    
    
    list(lin_reg = lin_reg, tree = tree, rf = rf, test_data = test_data)
  }, ignoreNULL = FALSE)
  
  output$lin_reg_summary <- renderPrint({
    if(is.null(model_fits()$lin_reg)) {
      return(NULL)
    }
    summary(model_fits()$lin_reg)
  })
  
  output$tree_summary <- renderPrint({
    if(is.null(model_fits()$tree)) {
      return(NULL)
    }
    summary(model_fits()$tree)
  })
  
  output$rf_summary <- renderPrint({
    if(is.null(model_fits()$rf)) {
      return(NULL)
    }
    summary(model_fits()$rf)
  })
  

  test_stats <- reactive({
    model_fits <- model_fits()
    test_data <- model_fits$test_data
    if (is.null(test_data) || is.null(model_fits)) {
      return(NULL)
    }
    rmse <- sapply(model_fits[1:3], function(model) {
      if(is.null(model)) {
        return(NULL)
      }
      preds <- predict(model, newdata = test_data)
      sqrt(mean((test_data$dependent_var - preds)^2))
    })
    if(!is.null(rmse)) {
      names(rmse) <- c("Linear Regression", "Tree", "Random Forest")
    }
    rmse
  })
  
  output$test_stats <- renderPrint({
    test_stats()
  })
  
  
  observeEvent(input$model_vars, {
    updateTabsetPanel(session, "tabs", selected = "prediction")
    output$predictor_inputs <- renderUI({
      map(input$model_vars, ~ textInput(.x, label = .x, value = median(WineQuality[[.x]], na.rm = TRUE)))
    })
  })
  
  prediction <- eventReactive(input$predict, {
    req(input$model_vars, input$prediction_model, model_fits())
    new_data <- do.call(cbind, lapply(input$model_vars, function(x) setNames(data.frame(as.numeric(input[[x]])), x)))
    model <- model_fits()[[tolower(input$prediction_model)]]
    
    if (is.null(model)) {
      return("Model not found. Please ensure that you have fit the model.")
    }
    
    round(predict(model, newdata = new_data))
  })
  
  output$prediction_output <- renderPrint({
    unname(prediction())
  })
  
  #DataPage
  output$column_checkboxes <- renderUI({
    checkboxGroupInput("columns", "Columns to display:", choices = names(WineQuality), selected = names(WineQuality))
  })
  
  output$data_table <- DT::renderDT({
    DT::datatable(WineQuality, options = list(pageLength = 10))
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      "data.csv"
    },
    content = function(file) {
      write.csv(wine[1:input$rows, input$columns], file, row.names = FALSE)
    }
  )
}